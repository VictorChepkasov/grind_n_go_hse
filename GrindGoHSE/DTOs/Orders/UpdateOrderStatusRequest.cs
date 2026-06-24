using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Orders;

public class UpdateOrderStatusRequest
{
    [Required]
    [MaxLength(30)]
    public string Status { get; set; } = string.Empty;
}
