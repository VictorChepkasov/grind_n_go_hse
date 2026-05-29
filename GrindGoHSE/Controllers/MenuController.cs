using GrindGoHSE.DTOs.Menu;
using GrindGoHSE.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace GrindGoHSE.Controllers;

[ApiController]
[Route("api/[controller]")]
[AllowAnonymous]
public class MenuController(IMenuService menuService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult> GetMenu(CancellationToken cancellationToken)
    {
        var menu = await menuService.GetMenuAsync(cancellationToken);
        return Ok(menu);
    }

    [HttpGet("products/{productId:long}")]
    public async Task<ActionResult<MenuProductDto>> GetProduct(
        long productId,
        CancellationToken cancellationToken)
    {
        var product = await menuService.GetProductByIdAsync(productId, cancellationToken);
        if (product is null)
            return NotFound(new { message = "Товар не найден или недоступен." });

        return Ok(product);
    }

    [HttpGet("products/{productId:long}/photo")]
    public async Task<IActionResult> GetProductPhoto(
        long productId,
        CancellationToken cancellationToken)
    {
        var photo = await menuService.GetProductPhotoAsync(productId, cancellationToken);
        if (photo is null)
            return NotFound(new { message = "Фото не найдено." });

        return File(photo.Value.Data, photo.Value.ContentType);
    }
}
