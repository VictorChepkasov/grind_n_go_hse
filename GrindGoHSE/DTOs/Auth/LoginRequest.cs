using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Auth;

public class LoginRequest
{
    [Required]
    [MaxLength(20)]
    [Phone]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}
