namespace GrindGoHSE.DTOs.Menu;

public class MenuProductDto
{
    public long ProductId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool HasPhoto { get; set; }
    public IReadOnlyList<MenuProductSizeDto> Sizes { get; set; } = [];
}
