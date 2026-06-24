using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.DTOs.Auth;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class AuthService(
    AppDbContext db,
    IPasswordHasher passwordHasher,
    IJwtTokenService jwtTokenService) : IAuthService
{
    public async Task<AuthResponse> RegisterAsync(
        RegisterRequest request,
        CancellationToken cancellationToken = default)
    {
        var phone = NormalizePhone(request.PhoneNumber);

        if (await db.Users.AnyAsync(u => u.PhoneNumber == phone, cancellationToken))
            throw new InvalidOperationException("Пользователь с таким номером телефона уже существует.");

        var user = new AppUser
        {
            Name = request.Name.Trim(),
            PhoneNumber = phone,
            PasswordHash = passwordHasher.Hash(request.Password),
            Language = string.IsNullOrWhiteSpace(request.Language) ? "ru" : request.Language.Trim(),
            Role = UserRoles.Client
        };

        db.Users.Add(user);
        await db.SaveChangesAsync(cancellationToken);

        return ToAuthResponse(user, jwtTokenService.CreateToken(user));
    }

    public async Task<AuthResponse?> LoginAsync(
        LoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var phone = NormalizePhone(request.PhoneNumber);

        var user = await db.Users
            .FirstOrDefaultAsync(u => u.PhoneNumber == phone, cancellationToken);

        if (user is null || !passwordHasher.Verify(request.Password, user.PasswordHash))
            return null;

        return ToAuthResponse(user, jwtTokenService.CreateToken(user));
    }

    private static string NormalizePhone(string phone)
    {
        var digits = new string(phone.Where(char.IsDigit).ToArray());

        if (digits.Length == 10)
            return "+7" + digits;

        if (digits.Length == 11 && digits.StartsWith('7'))
            return "+" + digits;

        if (digits.Length == 11 && digits.StartsWith('8'))
            return "+7" + digits[1..];

        return phone.Trim();
    }

    private static AuthResponse ToAuthResponse(AppUser user, string token) => new()
    {
        Token = token,
        UserId = user.UserId,
        Name = user.Name,
        PhoneNumber = user.PhoneNumber,
        Role = user.Role,
        Language = user.Language
    };
}
