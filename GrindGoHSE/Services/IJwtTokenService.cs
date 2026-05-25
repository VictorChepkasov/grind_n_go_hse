using GrindGoHSE.Data.Entities;

namespace GrindGoHSE.Services;

public interface IJwtTokenService
{
    string CreateToken(AppUser user);
}
