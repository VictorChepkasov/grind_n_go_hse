namespace GrindGoHSE.Services.Notifications;

/// <summary>
/// Заглушка до подключения Firebase Cloud Messaging.
/// </summary>
public class NoOpNotificationService(ILogger<NoOpNotificationService> logger) : INotificationService
{
    public Task NotifyClientOrderStatusChangedAsync(
        long userId,
        long orderId,
        string status,
        CancellationToken cancellationToken = default)
    {
        logger.LogDebug(
            "FCM stub: order {OrderId} status «{Status}» for user {UserId}",
            orderId,
            status,
            userId);
        return Task.CompletedTask;
    }

    public Task NotifyBaristaNewOrderAsync(long orderId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("FCM stub: new order {OrderId} for barista", orderId);
        return Task.CompletedTask;
    }
}
