using GrindGoHSE.Constants;
using GrindGoHSE.Data;
using GrindGoHSE.Data.Entities;
using GrindGoHSE.DTOs.Admin;
using Microsoft.EntityFrameworkCore;

namespace GrindGoHSE.Services;

public class AdminService(AppDbContext db, IPasswordHasher passwordHasher) : IAdminService
{
    public async Task<long> CreateBaristaAsync(
        CreateBaristaRequest request,
        CancellationToken cancellationToken = default)
    {
        var phone = request.PhoneNumber.Trim();

        if (await db.Users.AnyAsync(u => u.PhoneNumber == phone, cancellationToken))
            throw new InvalidOperationException("Пользователь с таким номером телефона уже существует.");

        var barista = new AppUser
        {
            Name = request.Name.Trim(),
            PhoneNumber = phone,
            PasswordHash = passwordHasher.Hash(request.Password),
            Language = "ru",
            Role = UserRoles.Barista
        };

        db.Users.Add(barista);
        await db.SaveChangesAsync(cancellationToken);

        return barista.UserId;
    }
}
