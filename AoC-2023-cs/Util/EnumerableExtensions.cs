using AoC2023.Util;
using System.Numerics;

namespace AoC2023;

internal static class EnumerableExtensions
{
    internal static int Product(this IEnumerable<int> items)
        => items.Aggregate(1, (current, item) => current * item);

    internal static T GreatestCommonDivider<T>(this IEnumerable<T> items) where T : INumber<T>
        => items.Aggregate(items.First(), (current, item) => MathUtils.Gcd(current, item));

    internal static T LeastCommonMultiple<T>(this IEnumerable<T> items) where T : INumber<T>
        => items.Aggregate(items.First(), (current, item) => MathUtils.Lcm(current, item));
}
