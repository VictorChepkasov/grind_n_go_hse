using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Orders;

public class CreateOrderItemRequest
{
    [Required]
    public long ProductSizeId { get; set; }

    [Range(1, 99)]
<<<<<<< HEAD
    public int Quantity { get; set; }
=======
    public int Quantity { get; set; } = 1;
>>>>>>> origin/main
}
