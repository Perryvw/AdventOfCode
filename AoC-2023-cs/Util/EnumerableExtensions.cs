using AoC2023.Util;
using System;
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

    internal static IEnumerable<IEnumerable<T>> Rows<T>(this IEnumerable<IEnumerable<T>> items)
        => items;

    internal static IEnumerable<IEnumerable<T>> Columns<T>(this IEnumerable<IEnumerable<T>> items)
    {
        var width = items.First().Count();
        var height = items.Count();
        return Enumerable.Range(0, width)
            .Select(x => Enumerable.Range(0, height)
            .Select(y => items.ElementAt(y).ElementAt(x)));
    }

    internal static IEnumerable<(int Index, T Value)> Enumerate<T>(this IEnumerable<T> items)
        => items.Select((item, i) => (i, item));

    internal static IEnumerable<(T, T)> DifferentCombinations<T>(this IEnumerable<T> items)
    {
        var list = items.ToList();
        for (var i = 0; i < list.Count; i++)
        {
            for (var j = i + 1; j < list.Count; j++)
            {
                yield return (list[i], list[j]);
            }
        }
    }

    internal static IEnumerable<T> Repeat<T>(this IEnumerable<T> items, int count) => items.Repeat(count, Enumerable.Empty<T>());

    internal static IEnumerable<T> Repeat<T>(this IEnumerable<T> items, int count, IEnumerable<T> fill)
    {
        if (count == 0) yield break;

        var list = items.ToList();
        var fillList = fill.ToList();
        for (var i = 0; i < count; i++)
        {
            foreach (var item in list)
            {
                yield return item;
            }
            if (i < count - 1)
            {
                foreach (var item in fillList)
                {
                    yield return item;
                }
            }
        }
    }
}
