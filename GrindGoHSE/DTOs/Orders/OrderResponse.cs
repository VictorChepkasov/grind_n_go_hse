namespace GrindGoHSE.DTOs.Orders;

public class OrderResponse
{
    public long OrderId { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal TotalPrice { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
<<<<<<< HEAD
    public string? CustomerName { get; set; }
    public List<OrderItemResponse> Items { get; set; } = [];
=======
    public string? ClientName { get; set; }
    public IReadOnlyList<OrderItemResponse> Items { get; set; } = [];
>>>>>>> origin/main
}
