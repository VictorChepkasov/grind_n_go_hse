namespace GrindGoHSE.Data.Entities;

public class Size
{
    public long SizeId { get; set; }
    public string Name { get; set; } = string.Empty;

    public ICollection<ProductSize> ProductSizes { get; set; } = [];
}
