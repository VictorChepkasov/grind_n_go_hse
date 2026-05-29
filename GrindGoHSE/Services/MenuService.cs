using GrindGoHSE.Data;
using GrindGoHSE.DTOs.Menu;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class MenuService(AppDbContext db) : IMenuService
{
    public async Task<MenuResponse> GetMenuAsync(CancellationToken cancellationToken = default)
    {
        var products = await db.Products
            .AsNoTracking()
            .Where(p => p.IsAvailable)
            .Include(p => p.ProductSizes)
                .ThenInclude(ps => ps.Size)
            .OrderBy(p => p.Category)
            .ThenBy(p => p.Name)
            .ToListAsync(cancellationToken);

        var categories = products
            .GroupBy(p => p.Category)
            .Select(g => new MenuCategoryDto
            {
                Category = g.Key,
                Products = g.Select(MapProduct).ToList()
            })
            .ToList();

        return new MenuResponse { Categories = categories };
    }

    public async Task<MenuProductDto?> GetProductByIdAsync(
        long productId,
        CancellationToken cancellationToken = default)
    {
        var product = await db.Products
            .AsNoTracking()
            .Where(p => p.IsAvailable && p.ProductId == productId)
            .Include(p => p.ProductSizes)
                .ThenInclude(ps => ps.Size)
            .FirstOrDefaultAsync(cancellationToken);

        return product is null ? null : MapProduct(product);
    }

    public async Task<(byte[] Data, string ContentType)?> GetProductPhotoAsync(
        long productId,
        CancellationToken cancellationToken = default)
    {
        var product = await db.Products
            .AsNoTracking()
            .Where(p => p.IsAvailable && p.ProductId == productId)
            .Select(p => new { p.Photo })
            .FirstOrDefaultAsync(cancellationToken);

        if (product?.Photo is null or { Length: 0 })
            return null;

        return (product.Photo, "image/jpeg");
    }

    private static MenuProductDto MapProduct(Data.Entities.Product product) => new()
    {
        ProductId = product.ProductId,
        Name = product.Name,
        Description = product.Description,
        HasPhoto = product.Photo is { Length: > 0 },
        Sizes = product.ProductSizes
            .OrderBy(ps => ps.Size.SizeId)
            .Select(ps => new MenuProductSizeDto
            {
                ProductSizeId = ps.ProductSizeId,
                SizeId = ps.SizeId,
                SizeName = ps.Size.Name,
                Price = ps.Price
            })
            .ToList()
    };
}
