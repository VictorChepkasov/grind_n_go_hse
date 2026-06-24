namespace GrindGoHSE.DTOs.Orders;

public class OrderResponse
{
    public long OrderId { get; set; }
    public string Status { get; set; } = string.Empty;
    public decimal TotalPrice { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public string? CustomerName { get; set; }
    public List<OrderItemResponse> Items { get; set; } = [];
}
