namespace GrindGoHSE.Data.Entities;

public class ProductSize
{
    public long ProductSizeId { get; set; }
    public long ProductId { get; set; }
    public long SizeId { get; set; }
    public decimal Price { get; set; }

    public Product Product { get; set; } = null!;
    public Size Size { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = [];
}
