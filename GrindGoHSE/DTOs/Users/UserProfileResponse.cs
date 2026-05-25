namespace GrindGoHSE.DTOs.Users;

public class UserProfileResponse
{
    public long UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public string Language { get; set; } = string.Empty;
}
