namespace GrindGoHSE.Services.Notifications;

public interface INotificationService
{
    /// <param name="notifyBaristas">true при создании заказа — уведомить всех бариста.</param>
    Task NotifyOrderStatusAsync(
        long orderId,
        long clientUserId,
        string status,
        bool notifyBaristas = false,
        CancellationToken cancellationToken = default);
}
