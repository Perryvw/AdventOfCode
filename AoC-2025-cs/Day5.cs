using System.Numerics;

namespace AoC_2025_cs;

public class Day5
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var input = (await File.ReadAllTextAsync("../../../data/day5.txt", TestContext.Current.CancellationToken)).Split("\n\n");
        var ranges = input[0].Split("\n");
        var availableIds = input[1].Split("\n").Select(long.Parse).ToArray();

        // p1
        List<Interval<long>> freshRanges = [];
        foreach (var range in ranges)
        {
            var spl = range.Split("-");
            freshRanges.Add(new Interval<long>
            {
                From = long.Parse(spl[0]),
                To = long.Parse(spl[1]),
            });
        }

        foreach (var availableId in availableIds)
        {
            if (freshRanges.Any(range => range.Contains(availableId)))
            {
                p1++;
            }
        }

        // p2
        freshRanges.Sort((a, b) => a.From < b.From ? -1 : 1);

        HashSet<int> skip = [];

        for (var i = 0; i < freshRanges.Count; i++)
        {
            if (skip.Contains(i)) continue;

            var max = freshRanges[i].To;
            for (var j = i + 1; j < freshRanges.Count; j++)
            {
                if (freshRanges[j].From <= max)
                {
                    max = freshRanges[j].To > max ? freshRanges[j].To : max;
                    skip.Add(j);
                }
                else
                {
                    break;
                }
            }
            p2 += max - freshRanges[i].From + 1;
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    record struct Interval<T> where T : INumber<T>
    {
        public T From;
        public T To;

        public readonly T Size => To - From + T.One;

        public readonly bool Contains(T value) => From <= value && To >= value;

        public readonly bool Overlaps(Interval<T> other) => (From <= other.To && From >= other.From) || (To >= other.From && To <= other.To);

        public readonly Interval<T> Combine(Interval<T> other) => new Interval<T>
        {
            From = From < other.From ? From : other.From,
            To = To > other.To ? To : other.To
        };

        public override string ToString() => $"({From}\n {To})";
    }
}
