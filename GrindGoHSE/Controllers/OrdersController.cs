using System.Security.Claims;
using GrindGoHSE.Constants;
using GrindGoHSE.DTOs.Orders;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class OrdersController(IOrderService orderService) : ControllerBase
{
    [HttpPost]
    [Authorize(Roles = UserRoles.Client)]
<<<<<<< HEAD
    public async Task<ActionResult<OrderResponse>> CreateOrder(
=======
    public async Task<ActionResult<OrderResponse>> Create(
>>>>>>> origin/main
        [FromBody] CreateOrderRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        try
        {
<<<<<<< HEAD
            var order = await orderService.CreateOrderAsync(
                userId.Value,
                request,
                cancellationToken);
            return CreatedAtAction(nameof(GetMyOrders), new { id = order.OrderId }, order);
=======
            var order = await orderService.CreateOrderAsync(userId.Value, request, cancellationToken);
            return Ok(order);
>>>>>>> origin/main
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

<<<<<<< HEAD
    [HttpGet("me")]
    [Authorize(Roles = UserRoles.Client)]
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetMyOrders(
        CancellationToken cancellationToken)
=======
    [HttpGet("my")]
    [Authorize(Roles = UserRoles.Client)]
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetMyOrders(CancellationToken cancellationToken)
>>>>>>> origin/main
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var orders = await orderService.GetMyOrdersAsync(userId.Value, cancellationToken);
        return Ok(orders);
    }

    [HttpGet("queue")]
    [Authorize(Roles = UserRoles.Barista)]
<<<<<<< HEAD
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetQueue(
        CancellationToken cancellationToken)
    {
        var orders = await orderService.GetBaristaQueueAsync(cancellationToken);
        return Ok(orders);
    }

=======
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetQueue(CancellationToken cancellationToken)
    {
        var orders = await orderService.GetQueueAsync(cancellationToken);
        return Ok(orders);
    }

    [HttpGet("{orderId:long}")]
    public async Task<ActionResult<OrderResponse>> GetById(long orderId, CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        var role = GetCurrentUserRole();
        if (userId is null || role is null)
            return Unauthorized();

        var order = await orderService.GetOrderAsync(orderId, userId.Value, role, cancellationToken);
        if (order is null)
            return NotFound(new { message = "Заказ не найден." });

        return Ok(order);
    }

>>>>>>> origin/main
    [HttpPatch("{orderId:long}/status")]
    [Authorize(Roles = UserRoles.Barista)]
    public async Task<ActionResult<OrderResponse>> UpdateStatus(
        long orderId,
        [FromBody] UpdateOrderStatusRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        try
        {
<<<<<<< HEAD
            var order = await orderService.UpdateStatusAsync(
                orderId,
                request.Status,
                cancellationToken);

=======
            var order = await orderService.UpdateStatusAsync(orderId, request.Status, cancellationToken);
>>>>>>> origin/main
            if (order is null)
                return NotFound(new { message = "Заказ не найден." });

            return Ok(order);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private long? GetCurrentUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return long.TryParse(idClaim, out var userId) ? userId : null;
    }
<<<<<<< HEAD
=======

    private string? GetCurrentUserRole() => User.FindFirstValue(ClaimTypes.Role);
>>>>>>> origin/main
}
