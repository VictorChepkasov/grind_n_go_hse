namespace GrindGoHSE.Services;

public interface IBaristaProductService
{
    Task<bool> SetAvailabilityAsync(
        long productId,
        bool isAvailable,
        CancellationToken cancellationToken = default);
}
