namespace AoC2023;

internal static class EnumerableExtensions
{
    internal static int Product(this IEnumerable<int> items)
        => items.Aggregate(1, (current, item) => current * item);
}
