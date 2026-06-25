using GrindGoHSE.DTOs.Barista;

namespace GrindGoHSE.Services;

public interface IBaristaProductService
{
    Task<BaristaMenuResponse> GetMenuAsync(CancellationToken cancellationToken = default);

    Task<(byte[] Data, string ContentType)?> GetProductPhotoAsync(
        long productId,
        CancellationToken cancellationToken = default);

    Task<bool> SetAvailabilityAsync(
        long productId,
        bool isAvailable,
        CancellationToken cancellationToken = default);
}
