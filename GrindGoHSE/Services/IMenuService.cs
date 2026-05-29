using GrindGoHSE.DTOs.Menu;

namespace GrindGoHSE.Services;

public interface IMenuService
{
    Task<MenuResponse> GetMenuAsync(CancellationToken cancellationToken = default);
    Task<MenuProductDto?> GetProductByIdAsync(long productId, CancellationToken cancellationToken = default);
    Task<(byte[] Data, string ContentType)?> GetProductPhotoAsync(
        long productId,
        CancellationToken cancellationToken = default);
}
