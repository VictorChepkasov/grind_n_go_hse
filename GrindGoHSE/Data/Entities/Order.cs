namespace GrindGoHSE.Data.Entities;

public class Order
{
    public long OrderId { get; set; }
    public long UserId { get; set; }
    public string Status { get; set; } = "создан";
    public decimal TotalPrice { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public AppUser User { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = [];
}
