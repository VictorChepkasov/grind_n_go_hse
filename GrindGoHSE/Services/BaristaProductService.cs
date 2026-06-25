using GrindGoHSE.Data;
using GrindGoHSE.DTOs.Barista;
using GrindGoHSE.DTOs.Menu;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class BaristaProductService(AppDbContext db) : IBaristaProductService
{
    public async Task<BaristaMenuResponse> GetMenuAsync(CancellationToken cancellationToken = default)
    {
        var products = await db.Products
            .AsNoTracking()
            .Include(p => p.ProductSizes)
                .ThenInclude(ps => ps.Size)
            .OrderBy(p => p.Category)
            .ThenBy(p => p.Name)
            .ToListAsync(cancellationToken);

        var categories = products
            .GroupBy(p => p.Category)
            .Select(g => new BaristaMenuCategoryDto
            {
                Category = g.Key,
                Products = g.Select(MapProduct).ToList()
            })
            .ToList();

        return new BaristaMenuResponse { Categories = categories };
    }

    public async Task<(byte[] Data, string ContentType)?> GetProductPhotoAsync(
        long productId,
        CancellationToken cancellationToken = default)
    {
        var product = await db.Products
            .AsNoTracking()
            .Where(p => p.ProductId == productId)
            .Select(p => new { p.Photo })
            .FirstOrDefaultAsync(cancellationToken);

        if (product?.Photo is null or { Length: 0 })
            return null;

        return (product.Photo, "image/jpeg");
    }

    public async Task<bool> SetAvailabilityAsync(
        long productId,
        bool isAvailable,
        CancellationToken cancellationToken = default)
    {
        var product = await db.Products.FirstOrDefaultAsync(p => p.ProductId == productId, cancellationToken);
        if (product is null)
            return false;

        product.IsAvailable = isAvailable;
        await db.SaveChangesAsync(cancellationToken);

        return true;
    }

    private static BaristaMenuProductDto MapProduct(Data.Entities.Product product) => new()
    {
        ProductId = product.ProductId,
        Name = product.Name,
        Description = product.Description,
        HasPhoto = product.Photo is { Length: > 0 },
        IsAvailable = product.IsAvailable,
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
