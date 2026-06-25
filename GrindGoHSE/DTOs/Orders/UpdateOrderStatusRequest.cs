using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Orders;

public class UpdateOrderStatusRequest
{
    [Required]
<<<<<<< HEAD
    [MaxLength(30)]
=======
>>>>>>> origin/main
    public string Status { get; set; } = string.Empty;
}
