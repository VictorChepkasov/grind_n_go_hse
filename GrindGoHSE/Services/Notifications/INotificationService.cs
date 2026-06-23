namespace GrindGoHSE.Services.Notifications;

public interface INotificationService
{
    Task NotifyClientOrderStatusChangedAsync(
        long userId,
        long orderId,
        string status,
        CancellationToken cancellationToken = default);
    Task NotifyBaristaNewOrderAsync(long orderId, CancellationToken cancellationToken = default);
}
