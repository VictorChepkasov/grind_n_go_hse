namespace GrindGoHSE.Options;

public class FirebaseSettings
{
    public const string SectionName = "Firebase";

    public bool Enabled { get; set; }
    public string ServiceAccountPath { get; set; } = string.Empty;
}
