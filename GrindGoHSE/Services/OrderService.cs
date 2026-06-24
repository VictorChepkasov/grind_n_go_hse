using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.DTOs.Orders;
using GrindGoHSE.Services.Notifications;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class OrderService(
    AppDbContext db,
    INotificationService notificationService) : IOrderService
{
    public async Task<OrderResponse> CreateOrderAsync(
        long userId,
        CreateOrderRequest request,
        CancellationToken cancellationToken = default)
    {
        if (request.Items.Count == 0)
            throw new InvalidOperationException("Корзина пуста.");

        var productSizeIds = request.Items
            .Select(i => i.ProductSizeId)
            .Distinct()
            .ToList();

        var productSizes = await db.ProductSizes
            .AsNoTracking()
            .Include(ps => ps.Product)
            .Include(ps => ps.Size)
            .Where(ps => productSizeIds.Contains(ps.ProductSizeId))
            .ToDictionaryAsync(ps => ps.ProductSizeId, cancellationToken);

        if (productSizes.Count != productSizeIds.Count)
            throw new InvalidOperationException("Некоторые позиции меню недоступны.");

        foreach (var item in request.Items)
        {
            if (item.Quantity <= 0)
                throw new InvalidOperationException("Количество должно быть больше нуля.");

            var productSize = productSizes[item.ProductSizeId];
            if (!productSize.Product.IsAvailable)
                throw new InvalidOperationException($"«{productSize.Product.Name}» сейчас недоступен.");
        }

        var order = new Order
        {
            UserId = userId,
            Status = OrderStatuses.Created,
            CreatedAt = DateTimeOffset.UtcNow,
            OrderItems = request.Items.Select(i => new OrderItem
            {
                ProductSizeId = i.ProductSizeId,
                Quantity = i.Quantity
            }).ToList()
        };

        order.TotalPrice = order.OrderItems.Sum(i =>
            productSizes[i.ProductSizeId].Price * i.Quantity);

        db.Orders.Add(order);
        await db.SaveChangesAsync(cancellationToken);

        await notificationService.NotifyBaristaNewOrderAsync(order.OrderId, cancellationToken);

        var user = await db.Users
            .AsNoTracking()
            .Where(u => u.UserId == userId)
            .Select(u => u.Name)
            .FirstAsync(cancellationToken);

        return MapOrder(order, productSizes, user);
    }

    public async Task<IReadOnlyList<OrderResponse>> GetMyOrdersAsync(
        long userId,
        CancellationToken cancellationToken = default)
    {
        var orders = await LoadOrdersQuery()
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .ToListAsync(cancellationToken);

        return orders.Select(MapLoadedOrder).ToList();
    }

    public async Task<IReadOnlyList<OrderResponse>> GetBaristaQueueAsync(
        CancellationToken cancellationToken = default)
    {
        var orders = await LoadOrdersQuery()
            .Where(o => OrderStatuses.ActiveQueue.Contains(o.Status))
            .OrderBy(o => o.CreatedAt)
            .ToListAsync(cancellationToken);

        return orders.Select(MapLoadedOrder).ToList();
    }

    public async Task<OrderResponse?> UpdateStatusAsync(
        long orderId,
        string newStatus,
        CancellationToken cancellationToken = default)
    {
        if (!IsValidStatus(newStatus))
            throw new InvalidOperationException("Недопустимый статус заказа.");

        var order = await db.Orders
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.ProductSize)
                    .ThenInclude(ps => ps.Product)
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.ProductSize)
                    .ThenInclude(ps => ps.Size)
            .Include(o => o.User)
            .FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);

        if (order is null)
            return null;

        if (!IsValidTransition(order.Status, newStatus))
            throw new InvalidOperationException(
                $"Нельзя перевести заказ из «{order.Status}» в «{newStatus}».");

        order.Status = newStatus;
        await db.SaveChangesAsync(cancellationToken);

        if (newStatus == OrderStatuses.Ready)
        {
            await notificationService.NotifyClientOrderReadyAsync(
                order.UserId,
                order.OrderId,
                cancellationToken);
        }

        return MapLoadedOrder(order);
    }

    private IQueryable<Order> LoadOrdersQuery() =>
        db.Orders
            .AsNoTracking()
            .Include(o => o.User)
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.ProductSize)
                    .ThenInclude(ps => ps.Product)
            .Include(o => o.OrderItems)
                .ThenInclude(i => i.ProductSize)
                    .ThenInclude(ps => ps.Size);

    private static bool IsValidStatus(string status) =>
        status is OrderStatuses.Created
            or OrderStatuses.InProgress
            or OrderStatuses.Cancelled
            or OrderStatuses.Ready;

    private static bool IsValidTransition(string current, string next) =>
        (current, next) switch
        {
            (OrderStatuses.Created, OrderStatuses.InProgress) => true,
            (OrderStatuses.Created, OrderStatuses.Cancelled) => true,
            (OrderStatuses.InProgress, OrderStatuses.Ready) => true,
            (OrderStatuses.InProgress, OrderStatuses.Cancelled) => true,
            _ => false
        };

    private static OrderResponse MapLoadedOrder(Order order)
    {
        var productSizes = order.OrderItems
            .ToDictionary(i => i.ProductSizeId, i => i.ProductSize);

        return MapOrder(order, productSizes, order.User.Name);
    }

    private static OrderResponse MapOrder(
        Order order,
        IReadOnlyDictionary<long, ProductSize> productSizes,
        string customerName) =>
        new()
        {
            OrderId = order.OrderId,
            Status = order.Status,
            TotalPrice = order.TotalPrice,
            CreatedAt = order.CreatedAt,
            CustomerName = customerName,
            Items = order.OrderItems.Select(i =>
            {
                var productSize = productSizes[i.ProductSizeId];
                return new OrderItemResponse
                {
                    ContainId = i.ContainId,
                    ProductSizeId = i.ProductSizeId,
                    ProductName = productSize.Product.Name,
                    SizeName = productSize.Size.Name,
                    Quantity = i.Quantity,
                    UnitPrice = productSize.Price,
                    LineTotal = productSize.Price * i.Quantity
                };
            }).ToList()
        };
}
