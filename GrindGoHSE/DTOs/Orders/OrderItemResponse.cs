namespace GrindGoHSE.DTOs.Orders;

public class OrderItemResponse
{
<<<<<<< HEAD
    public long ContainId { get; set; }
=======
>>>>>>> origin/main
    public long ProductSizeId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public string SizeName { get; set; } = string.Empty;
    public int Quantity { get; set; }
    public decimal UnitPrice { get; set; }
    public decimal LineTotal { get; set; }
}
