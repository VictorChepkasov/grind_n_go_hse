using GrindGoHSE.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext db, CancellationToken cancellationToken = default)
    {
        if (await db.Products.AnyAsync(cancellationToken))
            return;

        var sizes = new Dictionary<string, Size>
        {
            ["S"] = new() { Name = "S" },
            ["M"] = new() { Name = "M" },
            ["L"] = new() { Name = "L" }
        };

        db.Sizes.AddRange(sizes.Values);
        await db.SaveChangesAsync(cancellationToken);

        var drinks = new[]
        {
            new DrinkSeed("Капучино", "Кофе", "Эспрессо с молочной пеной", [150m, 180m, 210m]),
            new DrinkSeed("Латте", "Кофе", "Эспрессо с молоком", [160m, 190m, 220m]),
            new DrinkSeed("Американо", "Кофе", "Эспрессо с горячей водой", [120m, 140m, 160m]),
            new DrinkSeed("Эспрессо", "Кофе", "Классический эспрессо", [100m, 100m, 100m]),
            new DrinkSeed("Раф", "Кофе", "Кофе со сливками и ванилью", [190m, 220m, 250m]),
            new DrinkSeed("Чай чёрный", "Чай", "Классический чёрный чай", [90m, 110m, 130m]),
            new DrinkSeed("Чай зелёный", "Чай", "Зелёный чай", [90m, 110m, 130m]),
            new DrinkSeed("Какао", "Другое", "Горячее какао", [140m, 170m, 200m])
        };

        var sizeOrder = new[] { sizes["S"], sizes["M"], sizes["L"] };

        foreach (var drink in drinks)
        {
            var product = new Product
            {
                Name = drink.Name,
                Category = drink.Category,
                Description = drink.Description,
                IsAvailable = true
            };

            for (var i = 0; i < sizeOrder.Length; i++)
            {
                product.ProductSizes.Add(new ProductSize
                {
                    Size = sizeOrder[i],
                    Price = drink.Prices[i]
                });
            }

            db.Products.Add(product);
        }

        await db.SaveChangesAsync(cancellationToken);
    }

    private sealed record DrinkSeed(
        string Name,
        string Category,
        string Description,
        decimal[] Prices);
}
