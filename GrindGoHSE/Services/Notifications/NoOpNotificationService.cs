namespace GrindGoHSE.Services.Notifications;

/// <summary>
/// Заглушка, если Firebase не настроен.
/// </summary>
public class NoOpNotificationService(ILogger<NoOpNotificationService> logger) : INotificationService
{
    public Task NotifyOrderStatusAsync(
        long orderId,
        long clientUserId,
        string status,
        bool notifyBaristas = false,
        CancellationToken cancellationToken = default)
    {
        logger.LogDebug(
            "FCM stub: заказ {OrderId}, статус «{Status}», клиент {UserId}, бариста={NotifyBaristas}",
            orderId,
            status,
            clientUserId,
            notifyBaristas);
        return Task.CompletedTask;
    }
}
