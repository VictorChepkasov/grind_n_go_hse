using GrindGoHSE.DTOs.Users;

namespace GrindGoHSE.Services;

public interface IUserService
{
    Task<UserProfileResponse?> GetProfileAsync(long userId, CancellationToken cancellationToken = default);
    Task<UserProfileResponse?> UpdateProfileAsync(
        long userId,
        UpdateProfileRequest request,
        CancellationToken cancellationToken = default);
}
