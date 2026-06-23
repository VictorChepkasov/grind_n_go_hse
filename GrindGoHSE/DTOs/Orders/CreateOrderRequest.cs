using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Orders;

public class CreateOrderRequest
{
    [Required]
    [MinLength(1)]
    public List<CreateOrderItemRequest> Items { get; set; } = [];
}
