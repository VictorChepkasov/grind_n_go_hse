using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class DeviceTokenService(AppDbContext db)
{
    public async Task RegisterAsync(long userId, string fcmToken, CancellationToken cancellationToken = default)
    {
        var token = fcmToken.Trim();
        if (string.IsNullOrWhiteSpace(token))
            throw new InvalidOperationException("FCM-токен не может быть пустым.");

        var existing = await db.DeviceTokens
            .FirstOrDefaultAsync(t => t.UserId == userId && t.FcmToken == token, cancellationToken);

        if (existing is not null)
            return;

        db.DeviceTokens.Add(new DeviceToken
        {
            UserId = userId,
            FcmToken = token,
            CreatedAt = DateTimeOffset.UtcNow
        });

        await db.SaveChangesAsync(cancellationToken);
    }
}
