using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Orders;

public class UpdateOrderStatusRequest
{
    [Required]
    public string Status { get; set; } = string.Empty;
}
