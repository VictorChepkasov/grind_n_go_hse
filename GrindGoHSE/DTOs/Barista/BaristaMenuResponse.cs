namespace GrindGoHSE.DTOs.Barista;

public class BaristaMenuResponse
{
    public IReadOnlyList<BaristaMenuCategoryDto> Categories { get; set; } = [];
}
