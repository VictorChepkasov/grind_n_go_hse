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
    public async Task<ActionResult<OrderResponse>> CreateOrder(
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
            var order = await orderService.CreateOrderAsync(
                userId.Value,
                request,
                cancellationToken);
            return CreatedAtAction(nameof(GetMyOrders), new { id = order.OrderId }, order);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("me")]
    [Authorize(Roles = UserRoles.Client)]
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetMyOrders(
        CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var orders = await orderService.GetMyOrdersAsync(userId.Value, cancellationToken);
        return Ok(orders);
    }

    [HttpGet("queue")]
    [Authorize(Roles = UserRoles.Barista)]
    public async Task<ActionResult<IReadOnlyList<OrderResponse>>> GetQueue(
        CancellationToken cancellationToken)
    {
        var orders = await orderService.GetBaristaQueueAsync(cancellationToken);
        return Ok(orders);
    }

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
            var order = await orderService.UpdateStatusAsync(
                orderId,
                request.Status,
                cancellationToken);

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
}
