using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Options;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace GrindGoHSE.Services.Notifications;

public class FcmNotificationService(
    AppDbContext db,
    IOptions<FirebaseSettings> options,
    ILogger<FcmNotificationService> logger) : INotificationService
{
    private readonly FirebaseSettings _settings = options.Value;

    public async Task NotifyOrderStatusAsync(
        long orderId,
        long clientUserId,
        string status,
        bool notifyBaristas = false,
        CancellationToken cancellationToken = default)
    {
        EnsureFirebaseInitialized();

        var title = $"Заказ №{orderId}";
        var body = $"Статус: {status}";
        var tag = $"order-{orderId}";

        var clientTokens = await GetTokensForUserAsync(clientUserId, cancellationToken);
        foreach (var token in clientTokens)
            await SendAsync(token, title, body, tag, orderId, status, cancellationToken);

        if (notifyBaristas)
        {
            var baristaTokens = await GetTokensForRoleAsync(UserRoles.Barista, cancellationToken);
            var baristaBody = $"Новый заказ №{orderId}. Статус: {status}";
            foreach (var token in baristaTokens)
                await SendAsync(token, title, baristaBody, tag, orderId, status, cancellationToken);
        }
    }

    private void EnsureFirebaseInitialized()
    {
        if (FirebaseApp.DefaultInstance is not null)
            return;

        if (string.IsNullOrWhiteSpace(_settings.ServiceAccountPath) || !File.Exists(_settings.ServiceAccountPath))
            throw new InvalidOperationException(
                $"Firebase: файл ключа не найден: {_settings.ServiceAccountPath}");

        FirebaseApp.Create(new AppOptions
        {
            Credential = GoogleCredential.FromFile(_settings.ServiceAccountPath)
        });
    }

    private async Task<List<string>> GetTokensForUserAsync(long userId, CancellationToken cancellationToken) =>
        await db.DeviceTokens
            .AsNoTracking()
            .Where(t => t.UserId == userId)
            .Select(t => t.FcmToken)
            .ToListAsync(cancellationToken);

    private async Task<List<string>> GetTokensForRoleAsync(string role, CancellationToken cancellationToken) =>
        await db.DeviceTokens
            .AsNoTracking()
            .Where(t => t.User.Role == role)
            .Select(t => t.FcmToken)
            .ToListAsync(cancellationToken);

    private async Task SendAsync(
        string token,
        string title,
        string body,
        string tag,
        long orderId,
        string status,
        CancellationToken cancellationToken)
    {
        var message = new Message
        {
            Token = token,
            Notification = new Notification
            {
                Title = title,
                Body = body
            },
            Data = new Dictionary<string, string>
            {
                ["orderId"] = orderId.ToString(),
                ["status"] = status
            },
            Android = new AndroidConfig
            {
                CollapseKey = tag,
                Notification = new AndroidNotification
                {
                    Tag = tag,
                    ChannelId = "orders"
                }
            },
            Apns = new ApnsConfig
            {
                Headers = new Dictionary<string, string>
                {
                    ["apns-collapse-id"] = tag
                },
                Aps = new Aps
                {
                    Alert = new ApsAlert
                    {
                        Title = title,
                        Body = body
                    }
                }
            }
        };

        try
        {
            var messageId = await FirebaseMessaging.DefaultInstance.SendAsync(message, cancellationToken);
            logger.LogInformation("FCM отправлено: {MessageId}, заказ {OrderId}", messageId, orderId);
        }
        catch (FirebaseMessagingException ex)
        {
            logger.LogWarning(ex, "FCM ошибка для заказа {OrderId}: {ErrorCode}", orderId, ex.MessagingErrorCode);

            if (ex.MessagingErrorCode is MessagingErrorCode.Unregistered or MessagingErrorCode.InvalidArgument)
                await RemoveInvalidTokenAsync(token, cancellationToken);
        }
    }

    private async Task RemoveInvalidTokenAsync(string token, CancellationToken cancellationToken)
    {
        var entity = await db.DeviceTokens.FirstOrDefaultAsync(t => t.FcmToken == token, cancellationToken);
        if (entity is null)
            return;

        db.DeviceTokens.Remove(entity);
        await db.SaveChangesAsync(cancellationToken);
        logger.LogInformation("Удалён недействительный FCM-токен");
    }
}
