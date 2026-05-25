namespace GrindGoHSE.Data.Entities;

public class Product
{
    public long ProductId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Category { get; set; } = string.Empty;
    public byte[]? Photo { get; set; }
    public bool IsAvailable { get; set; } = true;

    public ICollection<ProductSize> ProductSizes { get; set; } = [];
}
