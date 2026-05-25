namespace GrindGoHSE.Services.Notifications;

public interface INotificationService
{
    Task NotifyClientOrderReadyAsync(long userId, long orderId, CancellationToken cancellationToken = default);
    Task NotifyBaristaNewOrderAsync(long orderId, CancellationToken cancellationToken = default);
}
