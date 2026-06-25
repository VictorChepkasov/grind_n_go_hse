namespace GrindGoHSE.Constants;

public static class OrderStatuses
{
    public const string Created = "создан";
    public const string InProgress = "в работе";
    public const string Cancelled = "отменён";
    public const string Ready = "готов к выдаче";

<<<<<<< HEAD
    public static readonly string[] ActiveQueue = [Created, InProgress];
=======
    public static readonly string[] All = [Created, InProgress, Cancelled, Ready];

    public static readonly string[] ActiveQueue = [Created, InProgress];

    private static readonly Dictionary<string, HashSet<string>> AllowedTransitions = new()
    {
        [Created] = [InProgress, Cancelled],
        [InProgress] = [Ready, Cancelled],
        [Ready] = [],
        [Cancelled] = []
    };

    public static bool CanTransition(string from, string to) =>
        AllowedTransitions.TryGetValue(from, out var targets) && targets.Contains(to);
>>>>>>> origin/main
}
