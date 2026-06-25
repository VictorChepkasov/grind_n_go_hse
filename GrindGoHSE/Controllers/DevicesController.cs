using System.Security.Claims;
using GrindGoHSE.DTOs.Devices;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class DevicesController(DeviceTokenService deviceTokenService) : ControllerBase
{
    [HttpPost("fcm-token")]
    public async Task<IActionResult> RegisterFcmToken(
        [FromBody] RegisterFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (!long.TryParse(userIdClaim, out var userId))
            return Unauthorized();

        try
        {
            await deviceTokenService.RegisterAsync(userId, request.FcmToken, cancellationToken);
            return Ok(new { message = "FCM-токен сохранён." });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
