namespace GrindGoHSE.DTOs.Menu;

public class MenuCategoryDto
{
    public string Category { get; set; } = string.Empty;
    public IReadOnlyList<MenuProductDto> Products { get; set; } = [];
}
