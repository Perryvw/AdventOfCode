using System.Numerics;

public static class EnumerableExtensions
{
    public static long Product(this IEnumerable<long> enumerable)
    {
        long result = 1;
        foreach (var v in enumerable)
        {
            result *= v;
        }
        return result;
    }

    public static long Product(this IEnumerable<int> enumerable)
    {
        long result = 1;
        foreach (var v in enumerable)
        {
            result *= v;
        }
        return result;
    }
}