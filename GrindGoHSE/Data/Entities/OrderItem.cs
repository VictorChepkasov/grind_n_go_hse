namespace GrindGoHSE.Data.Entities;

public class OrderItem
{
    public long ContainId { get; set; }
    public long OrderId { get; set; }
    public long ProductSizeId { get; set; }
    public int Quantity { get; set; }

    public Order Order { get; set; } = null!;
    public ProductSize ProductSize { get; set; } = null!;
}
