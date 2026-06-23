using GrindGoHSE.Data;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class BaristaProductService(AppDbContext db) : IBaristaProductService
{
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
}
