namespace GrindGoHSE.Constants;

public static class OrderStatuses
{
    public const string Created = "создан";
    public const string InProgress = "в работе";
    public const string Cancelled = "отменён";
    public const string Ready = "готов к выдаче";

    public static readonly string[] ActiveQueue = [Created, InProgress];
}
