namespace GrindGoHSE.DTOs.Menu;

public class MenuProductSizeDto
{
    public long ProductSizeId { get; set; }
    public long SizeId { get; set; }
    public string SizeName { get; set; } = string.Empty;
    public decimal Price { get; set; }
}
