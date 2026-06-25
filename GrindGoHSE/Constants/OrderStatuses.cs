namespace GrindGoHSE.Constants;

public static class OrderStatuses
{
    public const string Created = "создан";
    public const string InProgress = "в работе";
    public const string Cancelled = "отменён";
    public const string Ready = "готов к выдаче";
    public const string Issued = "выдан";

    public static readonly string[] All = [Created, InProgress, Cancelled, Ready, Issued];

    public static readonly string[] BaristaQueue = [Created, InProgress, Ready];

    public static readonly string[] ClientActive = [Created, InProgress, Ready];

    private static readonly Dictionary<string, HashSet<string>> AllowedTransitions = new()
    {
        [Created] = [InProgress, Cancelled],
        [InProgress] = [Ready, Cancelled],
        [Ready] = [Issued],
        [Issued] = [],
        [Cancelled] = []
    };

    public static bool CanTransition(string from, string to) =>
        AllowedTransitions.TryGetValue(from, out var targets) && targets.Contains(to);
}
