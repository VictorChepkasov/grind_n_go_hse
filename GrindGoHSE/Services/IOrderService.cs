using GrindGoHSE.DTOs.Orders;

namespace GrindGoHSE.Services;

public interface IOrderService
{
    Task<OrderResponse> CreateOrderAsync(
        long userId,
        CreateOrderRequest request,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<OrderResponse>> GetMyOrdersAsync(
        long userId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<OrderResponse>> GetBaristaQueueAsync(
        CancellationToken cancellationToken = default);

    Task<OrderResponse?> UpdateStatusAsync(
        long orderId,
        string newStatus,
        CancellationToken cancellationToken = default);
}
