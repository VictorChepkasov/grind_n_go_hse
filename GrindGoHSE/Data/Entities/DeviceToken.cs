namespace GrindGoHSE.Data.Entities;

public class DeviceToken
{
    public long TokenId { get; set; }
    public long UserId { get; set; }
    public string FcmToken { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }

    public AppUser User { get; set; } = null!;
}
