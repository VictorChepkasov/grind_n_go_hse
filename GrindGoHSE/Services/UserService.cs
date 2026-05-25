using GrindGoHSE.Data;
using GrindGoHSE.DTOs.Users;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class UserService(AppDbContext db) : IUserService
{
    public async Task<UserProfileResponse?> GetProfileAsync(
        long userId,
        CancellationToken cancellationToken = default)
    {
        var user = await db.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.UserId == userId, cancellationToken);

        return user is null ? null : ToResponse(user);
    }

    public async Task<UserProfileResponse?> UpdateProfileAsync(
        long userId,
        UpdateProfileRequest request,
        CancellationToken cancellationToken = default)
    {
        var user = await db.Users.FirstOrDefaultAsync(u => u.UserId == userId, cancellationToken);
        if (user is null)
            return null;

        if (!string.IsNullOrWhiteSpace(request.Name))
            user.Name = request.Name.Trim();

        if (!string.IsNullOrWhiteSpace(request.Language))
            user.Language = request.Language.Trim();

        await db.SaveChangesAsync(cancellationToken);

        return ToResponse(user);
    }

    private static UserProfileResponse ToResponse(Data.Entities.AppUser user) => new()
    {
        UserId = user.UserId,
        Name = user.Name,
        PhoneNumber = user.PhoneNumber,
        Role = user.Role,
        Language = user.Language
    };
}
