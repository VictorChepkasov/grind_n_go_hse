using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Data;

public static class ProductPhotoSeeder
{
    private static readonly Dictionary<string, string> FileToProductName = new(StringComparer.OrdinalIgnoreCase)
    {
        ["какао.jpg"] = "Какао",
        ["американо.jpg"] = "Американо",
        ["капуч.jpg"] = "Капучино",
        ["латте.jpg"] = "Латте",
        ["раф.jpg"] = "Раф",
        ["эспрессо.jpg"] = "Эспрессо",
        ["чай_зеленый.jpg"] = "Чай зеленый",
        ["чай_нигер.jpg"] = "Чай черный"
    };

    public static async Task SeedPhotosAsync(
        AppDbContext db,
        string photosFolder,
        CancellationToken cancellationToken = default)
    {
        if (!Directory.Exists(photosFolder))
            throw new DirectoryNotFoundException($"Папка с фото не найдена: {photosFolder}");

        var products = await db.Products.ToListAsync(cancellationToken);
        var updated = 0;

        foreach (var (fileName, productName) in FileToProductName)
        {
            var filePath = Path.Combine(photosFolder, fileName);
            if (!File.Exists(filePath))
            {
                Console.WriteLine($"Пропуск: файл не найден — {fileName}");
                continue;
            }

            var product = products.FirstOrDefault(p =>
                p.Name.Equals(productName, StringComparison.OrdinalIgnoreCase));

            if (product is null)
            {
                Console.WriteLine($"Пропуск: товар «{productName}» не найден в БД");
                continue;
            }

            product.Photo = await File.ReadAllBytesAsync(filePath, cancellationToken);
            updated++;
            Console.WriteLine($"Загружено фото для «{product.Name}» ({fileName})");
        }

        await db.SaveChangesAsync(cancellationToken);
        Console.WriteLine($"Готово. Обновлено товаров: {updated}.");
    }
}
