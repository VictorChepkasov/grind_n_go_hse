using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Devices;

public class RegisterFcmTokenRequest
{
    [Required]
    public string FcmToken { get; set; } = string.Empty;
}
