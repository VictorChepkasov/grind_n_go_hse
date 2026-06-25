using GrindGoHSE.Constants;
using GrindGoHSE.DTOs.Admin;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = UserRoles.Admin)]
public class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpPost("users")]
    public async Task<ActionResult> CreateBarista(
        [FromBody] CreateBaristaRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
            return ValidationProblem(ModelState);

        try
        {
            var userId = await adminService.CreateBaristaAsync(request, cancellationToken);
            return Ok(new { userId, role = UserRoles.Barista, message = "Бариста создан." });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }
}
