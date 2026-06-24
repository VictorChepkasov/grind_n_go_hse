using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.DTOs.Orders;
using GrindGoHSE.Services.Notifications;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class OrderService(AppDbContext db, INotificationService notifications) : IOrderService
{
    public async Task<OrderResponse> CreateOrderAsync(
        long userId,
        CreateOrderRequest request,
        CancellationToken cancellationToken = default)
    {
        var items = request.Items
            .GroupBy(i => i.ProductSizeId)
            .Select(g => new CreateOrderItemRequest
            {
                ProductSizeId = g.Key,
                Quantity = g.Sum(x => x.Quantity)
            })
            .ToList();

        var productSizeIds = items.Select(i => i.ProductSizeId).ToList();

        await using var transaction = await db.Database.BeginTransactionAsync(cancellationToken);

        var productSizes = await db.ProductSizes
            .Include(ps => ps.Product)
            .Include(ps => ps.Size)
            .Where(ps => productSizeIds.Contains(ps.ProductSizeId))
            .ToListAsync(cancellationToken);

        if (productSizes.Count != productSizeIds.Count)
            throw new InvalidOperationException("Одна или несколько позиций меню не найдены.");

        var unavailable = productSizes.Where(ps => !ps.Product.IsAvailable).ToList();
        if (unavailable.Count > 0)
        {
            var names = string.Join(", ", unavailable.Select(ps => ps.Product.Name));
            throw new InvalidOperationException($"Товары недоступны для заказа: {names}.");
        }

        var priceById = productSizes.ToDictionary(ps => ps.ProductSizeId);
        decimal totalPrice = 0;
        var orderItems = new List<OrderItem>();

        foreach (var item in items)
        {
            var productSize = priceById[item.ProductSizeId];
            totalPrice += productSize.Price * item.Quantity;

            orderItems.Add(new OrderItem
            {
                ProductSizeId = item.ProductSizeId,
                Quantity = item.Quantity
            });
        }

        var order = new Order
        {
            UserId = userId,
            Status = OrderStatuses.Created,
            TotalPrice = totalPrice,
            CreatedAt = DateTimeOffset.UtcNow,
            OrderItems = orderItems
        };

        db.Orders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);

        await notifications.NotifyOrderStatusAsync(
            order.OrderId,
            userId,
            OrderStatuses.Created,
            notifyBaristas: true,
            cancellationToken);

        return await MapOrderAsync(order.OrderId, includeClientName: false, cancellationToken)
            ?? throw new InvalidOperationException("Не удалось загрузить созданный заказ.");
    }

    public async Task<IReadOnlyList<OrderResponse>> GetMyOrdersAsync(
        long userId,
        CancellationToken cancellationToken = default)
    {
        var orderIds = await db.Orders
            .AsNoTracking()
            .Where(o => o.UserId == userId)
            .OrderByDescending(o => o.CreatedAt)
            .Select(o => o.OrderId)
            .ToListAsync(cancellationToken);

        var result = new List<OrderResponse>();
        foreach (var orderId in orderIds)
        {
            var order = await MapOrderAsync(orderId, includeClientName: false, cancellationToken);
            if (order is not null)
                result.Add(order);
        }

        return result;
    }

    public async Task<OrderResponse?> GetOrderAsync(
        long orderId,
        long userId,
        string userRole,
        CancellationToken cancellationToken = default)
    {
        var order = await db.Orders
            .AsNoTracking()
            .FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);

        if (order is null)
            return null;

        if (userRole == UserRoles.Client && order.UserId != userId)
            return null;

        return await MapOrderAsync(
            orderId,
            includeClientName: userRole is UserRoles.Barista or UserRoles.Admin,
            cancellationToken);
    }

    public async Task<IReadOnlyList<OrderResponse>> GetQueueAsync(CancellationToken cancellationToken = default)
    {
        var orderIds = await db.Orders
            .AsNoTracking()
            .Where(o => OrderStatuses.ActiveQueue.Contains(o.Status))
            .OrderBy(o => o.CreatedAt)
            .Select(o => o.OrderId)
            .ToListAsync(cancellationToken);

        var result = new List<OrderResponse>();
        foreach (var orderId in orderIds)
        {
            var order = await MapOrderAsync(orderId, includeClientName: true, cancellationToken);
            if (order is not null)
                result.Add(order);
        }

        return result;
    }

    public async Task<OrderResponse?> UpdateStatusAsync(
        long orderId,
        string newStatus,
        CancellationToken cancellationToken = default)
    {
        if (!OrderStatuses.All.Contains(newStatus))
            throw new InvalidOperationException("Недопустимый статус заказа.");

        var order = await db.Orders.FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);
        if (order is null)
            return null;

        if (!OrderStatuses.CanTransition(order.Status, newStatus))
            throw new InvalidOperationException($"Нельзя сменить статус с «{order.Status}» на «{newStatus}».");

        order.Status = newStatus;
        await db.SaveChangesAsync(cancellationToken);

        await notifications.NotifyOrderStatusAsync(
            order.OrderId,
            order.UserId,
            newStatus,
            notifyBaristas: false,
            cancellationToken);

        return await MapOrderAsync(orderId, includeClientName: true, cancellationToken);
    }

    private async Task<OrderResponse?> MapOrderAsync(
        long orderId,
        bool includeClientName,
        CancellationToken cancellationToken)
    {
        var order = await db.Orders
            .AsNoTracking()
            .Include(o => o.User)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.ProductSize)
                    .ThenInclude(ps => ps.Product)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.ProductSize)
                    .ThenInclude(ps => ps.Size)
            .FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);

        if (order is null)
            return null;

        return new OrderResponse
        {
            OrderId = order.OrderId,
            Status = order.Status,
            TotalPrice = order.TotalPrice,
            CreatedAt = order.CreatedAt,
            ClientName = includeClientName ? order.User.Name : null,
            Items = order.OrderItems.Select(oi => new OrderItemResponse
            {
                ProductSizeId = oi.ProductSizeId,
                ProductName = oi.ProductSize.Product.Name,
                SizeName = oi.ProductSize.Size.Name,
                Quantity = oi.Quantity,
                UnitPrice = oi.ProductSize.Price,
                LineTotal = oi.ProductSize.Price * oi.Quantity
            }).ToList()
        };
    }
}
