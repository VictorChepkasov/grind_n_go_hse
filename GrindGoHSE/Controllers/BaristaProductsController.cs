using GrindGoHSE.Constants;
using GrindGoHSE.DTOs.Barista;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/barista/products")]
[Authorize(Roles = UserRoles.Barista)]
public class BaristaProductsController(IBaristaProductService baristaProductService) : ControllerBase
{
    [HttpPatch("{productId:long}/availability")]
    public async Task<IActionResult> SetAvailability(
        long productId,
        [FromBody] UpdateProductAvailabilityRequest request,
        CancellationToken cancellationToken)
    {
        var updated = await baristaProductService.SetAvailabilityAsync(
            productId,
            request.IsAvailable,
            cancellationToken);

        if (!updated)
            return NotFound(new { message = "Товар не найден." });

        return Ok(new { productId, isAvailable = request.IsAvailable });
    }
}
