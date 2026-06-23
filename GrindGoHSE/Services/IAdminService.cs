using GrindGoHSE.DTOs.Admin;

namespace GrindGoHSE.Services;

public interface IAdminService
{
    Task<long> CreateBaristaAsync(CreateBaristaRequest request, CancellationToken cancellationToken = default);
}
