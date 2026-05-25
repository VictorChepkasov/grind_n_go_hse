using System.Security.Claims;
using GrindGoHSE.DTOs.Users;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController(IUserService userService) : ControllerBase
{
    [HttpGet("me")]
    public async Task<ActionResult<UserProfileResponse>> GetMe(CancellationToken cancellationToken)
    {
        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        var profile = await userService.GetProfileAsync(userId.Value, cancellationToken);
        if (profile is null)
            return NotFound(new { message = "Пользователь не найден." });

        return Ok(profile);
    }

    [HttpPatch("me")]
    public async Task<ActionResult<UserProfileResponse>> UpdateMe(
        [FromBody] UpdateProfileRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        var userId = GetCurrentUserId();
        if (userId is null)
            return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.Name) && string.IsNullOrWhiteSpace(request.Language))
            return BadRequest(new { message = "Укажите имя или язык для обновления." });

        var profile = await userService.UpdateProfileAsync(userId.Value, request, cancellationToken);
        if (profile is null)
            return NotFound(new { message = "Пользователь не найден." });

        return Ok(profile);
    }

    private long? GetCurrentUserId()
    {
        var idClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);
        return long.TryParse(idClaim, out var userId) ? userId : null;
    }
}
