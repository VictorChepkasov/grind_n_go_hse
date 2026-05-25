namespace GrindGoHSE.Data.Entities;

public class AppUser
{
    public long UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string PhoneNumber { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Language { get; set; } = "ru";
    public string Role { get; set; } = "client";

    public ICollection<Order> Orders { get; set; } = [];
    public ICollection<DeviceToken> DeviceTokens { get; set; } = [];
}
