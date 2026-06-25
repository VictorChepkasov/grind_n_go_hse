namespace GrindGoHSE.DTOs.Barista;

public class BaristaMenuCategoryDto
{
    public string Category { get; set; } = string.Empty;
    public IReadOnlyList<BaristaMenuProductDto> Products { get; set; } = [];
}
