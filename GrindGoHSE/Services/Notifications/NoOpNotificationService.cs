namespace GrindGoHSE.Services.Notifications;

/// <summary>
/// Заглушка до подключения Firebase Cloud Messaging.
/// </summary>
public class NoOpNotificationService(ILogger<NoOpNotificationService> logger) : INotificationService
{
    public Task NotifyClientOrderReadyAsync(long userId, long orderId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("FCM stub: order {OrderId} ready for user {UserId}", orderId, userId);
        return Task.CompletedTask;
    }

    public Task NotifyBaristaNewOrderAsync(long orderId, CancellationToken cancellationToken = default)
    {
        logger.LogDebug("FCM stub: new order {OrderId} for barista", orderId);
        return Task.CompletedTask;
    }
}
