using System.ComponentModel.DataAnnotations;

namespace GrindGoHSE.DTOs.Users;

public class UpdateProfileRequest
{
    [MaxLength(100)]
    public string? Name { get; set; }

    [MaxLength(10)]
    public string? Language { get; set; }
}
