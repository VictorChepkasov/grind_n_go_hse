using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.DTOs.Orders;
using GrindGoHSE.Services.Notifications;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

<<<<<<< HEAD
public class OrderService(
    AppDbContext db,
    INotificationService notificationService) : IOrderService
=======
public class OrderService(AppDbContext db, INotificationService notifications) : IOrderService
>>>>>>> origin/main
{
    public async Task<OrderResponse> CreateOrderAsync(
        long userId,
        CreateOrderRequest request,
        CancellationToken cancellationToken = default)
    {
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
        }

        var order = new Order
        {
            UserId = userId,
            Status = OrderStatuses.Created,
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
    }

    public async Task<IReadOnlyList<OrderResponse>> GetMyOrdersAsync(
        long userId,
        CancellationToken cancellationToken = default)
    {
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
    }

    public async Task<OrderResponse?> UpdateStatusAsync(
        long orderId,
        string newStatus,
        CancellationToken cancellationToken = default)
    {
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
            .FirstOrDefaultAsync(o => o.OrderId == orderId, cancellationToken);

        if (order is null)
            return null;

<<<<<<< HEAD
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
=======
        return new OrderResponse
>>>>>>> origin/main
        {
            OrderId = order.OrderId,
            Status = order.Status,
            TotalPrice = order.TotalPrice,
            CreatedAt = order.CreatedAt,
<<<<<<< HEAD
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
=======
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
>>>>>>> origin/main
}
