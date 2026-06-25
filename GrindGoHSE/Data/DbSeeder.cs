using GrindGoHSE.Constants;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.Services;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(AppDbContext db, CancellationToken cancellationToken = default)
    {
        await SeedAdminAsync(db, cancellationToken);
        await SeedMenuAsync(db, cancellationToken);
    }

    public static async Task ResetMenuAsync(AppDbContext db, CancellationToken cancellationToken = default)
    {
        await db.OrderItems.ExecuteDeleteAsync(cancellationToken);
        await db.ProductSizes.ExecuteDeleteAsync(cancellationToken);
        await db.Products.ExecuteDeleteAsync(cancellationToken);
        await db.Sizes.ExecuteDeleteAsync(cancellationToken);

        await SeedMenuDataAsync(db, cancellationToken);
    }

    private static async Task SeedAdminAsync(AppDbContext db, CancellationToken cancellationToken)
    {
        if (await db.Users.AnyAsync(u => u.Role == UserRoles.Admin, cancellationToken))
            return;

        db.Users.Add(new AppUser
        {
            Name = "Администратор",
            PhoneNumber = "+79990000000",
            PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
            Language = "ru",
            Role = UserRoles.Admin
        });

        await db.SaveChangesAsync(cancellationToken);
    }

    private static async Task SeedMenuAsync(AppDbContext db, CancellationToken cancellationToken)
    {
        if (await db.Products.AnyAsync(cancellationToken))
            return;

        await SeedMenuDataAsync(db, cancellationToken);
    }

    private static async Task SeedMenuDataAsync(AppDbContext db, CancellationToken cancellationToken)
    {
        var sizeNames = new[] { "s", "m", "l" };
        var sizes = sizeNames.ToDictionary(
            name => name,
            name => new Size { Name = name });

        db.Sizes.AddRange(sizes.Values);
        await db.SaveChangesAsync(cancellationToken);

        var menu = new[]
        {
            new ProductSeed(
                "Какао",
                "Другое",
                "Классическое сладкое какао. Состав: Молоко, какао, сахар. КБЖУ: 227 ккал, 8,4 г. белки, 9,2 г. жиры, 22,0 г. углеводы.",
                [("m", 210m), ("l", 250m)]),
            new ProductSeed(
                "Американо",
                "Кофе",
                "Популярный кофейный напиток, состоящий из одного или двух порций эспрессо. Состав: эспрессо. КБЖУ: 8 ккал, 0,3 г. белки, 0,3 г. жиры, 0,9 г. углеводы.",
                [("s", 150m), ("m", 180m), ("l", 210m)]),
            new ProductSeed(
                "Капучино",
                "Кофе",
                "Классический молочный напиток на основе эспрессо. Состав: молоко, эспрессо. КБЖУ: 159 ккал, 7,7 г. белки, 8,4 г. жиры, 12,2 г. углеводы.",
                [("s", 180m), ("m", 210m), ("l", 250m)]),
            new ProductSeed(
                "Латте",
                "Кофе",
                "Мягкий молочный напиток. Состав: молоко, эспрессо. КБЖУ: 156 ккал, 7,7 г. белки, 8,1 г. жиры, 11,9 г. углеводы.",
                [("m", 210m), ("l", 250m)]),
            new ProductSeed(
                "Раф",
                "Кофе",
                "Сливочная классика с бархатистой текстурой. Состав: сливки 10%, эспрессо. КБЖУ: 343 ккал, 6,7 г. белки, 25,2 г. жиры, 19,6 г. углеводы.",
                [("m", 270m), ("l", 300m)]),
            new ProductSeed(
                "Эспрессо",
                "Кофе",
                "Эспрессо из зерен, собранных в Колумбии, Бразилии и Перу. Состав: заваренный кофе. КБЖУ: 7 ккал, 0,3 г. белки, 0,3 г. жиры, 0,6 г. углеводы.",
                [("s", 150m), ("m", 180m), ("l", 210m)]),
            new ProductSeed(
                "Чай зеленый",
                "Чай",
                "Зеленый чай с легким цветочным ароматом. Состав: заваренный зеленый чай. КБЖУ: 0 ккал, 0,0 г. белки, 0,0 г. жиры, 0,0 г. углеводы.",
                [("s", 120m), ("m", 150m)]),
            new ProductSeed(
                "Чай черный",
                "Чай",
                "Выдержанный черный чай. Состав: заваренный пуэр. КБЖУ: 0 ккал, 0,0 г. белки, 0,0 г. жиры, 0,0 г. углеводы.",
                [("s", 120m), ("m", 150m)])
        };

        foreach (var item in menu)
        {
            var product = new Product
            {
                Name = item.Name,
                Category = item.Category,
                Description = item.Description,
                IsAvailable = item.SizePrices.Count > 0
            };

            foreach (var (sizeName, price) in item.SizePrices)
            {
                product.ProductSizes.Add(new ProductSize
                {
                    Size = sizes[sizeName],
                    Price = price
                });
            }

            db.Products.Add(product);
        }

        await db.SaveChangesAsync(cancellationToken);
    }

<<<<<<< HEAD
    public static async Task SeedBaristaAsync(
        AppDbContext db,
        IPasswordHasher passwordHasher,
        CancellationToken cancellationToken = default)
    {
        if (await db.Users.AnyAsync(u => u.Role == UserRoles.Barista, cancellationToken))
            return;

        db.Users.Add(new AppUser
        {
            Name = "Бариста",
            PhoneNumber = "+79991112233",
            PasswordHash = passwordHasher.Hash("barista123"),
            Role = UserRoles.Barista,
            Language = "ru"
        });

        await db.SaveChangesAsync(cancellationToken);
    }

    private sealed record DrinkSeed(
=======
    private sealed record ProductSeed(
>>>>>>> origin/main
        string Name,
        string Category,
        string Description,
        IReadOnlyList<(string Size, decimal Price)> SizePrices);
}
