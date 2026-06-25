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
    [HttpGet]
    public async Task<ActionResult<BaristaMenuResponse>> GetMenu(CancellationToken cancellationToken)
    {
        var menu = await baristaProductService.GetMenuAsync(cancellationToken);
        return Ok(menu);
    }

    [HttpGet("{productId:long}/photo")]
    public async Task<IActionResult> GetProductPhoto(
        long productId,
        CancellationToken cancellationToken)
    {
        var photo = await baristaProductService.GetProductPhotoAsync(productId, cancellationToken);
        if (photo is null)
            return NotFound(new { message = "Фото не найдено." });

        return File(photo.Value.Data, photo.Value.ContentType);
    }

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
