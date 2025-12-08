using AoC_2025_cs.Common;

namespace AoC_2025_cs;

using Point = (long x, long y, long z);

public class Day8
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var lines = await File.ReadAllLinesAsync("../../../data/day8.txt", TestContext.Current.CancellationToken);
        var junctionBoxes = lines.Select(l =>
        {
            var split = l.Split(",");
            return (x: long.Parse(split[0]), y: long.Parse(split[1]), z: long.Parse(split[2]));
        }).ToList();

        var CONNECT_TOGETHER = 1000;

        var pointsToConnect = Combinations(junctionBoxes.Count)
            .OrderBy(pair => Distance(junctionBoxes[pair.p1], junctionBoxes[pair.p2]));
        var i = 0;

        Dictionary<int, int> circuits = [];

        foreach (var p in pointsToConnect)
        {
            if (circuits.TryGetValue(p.p1, out int p1CircuitId) && circuits.TryGetValue(p.p2, out var p2CircuitId))
            {
                if (p1CircuitId != p2CircuitId)
                {
                    foreach (var p2CircuitJunction in circuits.Where(kvp => kvp.Value == p2CircuitId))
                    {
                        circuits[p2CircuitJunction.Key] = p1CircuitId;
                    }
                }
            }
            else if (circuits.TryGetValue(p.p1, out int circuitId))
            {
                circuits.Add(p.p2, circuitId);
            }
            else if (circuits.TryGetValue(p.p2, out int circuitId1))
            {
                circuits.Add(p.p1, circuitId1);
            }
            else
            {
                var newId = circuits.Count;
                circuits.Add(p.p1, newId);
                circuits.Add(p.p2, newId);
            }

            i++;
            if (i == CONNECT_TOGETHER)
            {
                p1 = circuits
                    .CountBy(kvp => kvp.Value)
                    .Select(group => group.Value)
                    .OrderDescending()
                    .Take(3)
                    .Product();
            }
            if (circuits.Count == junctionBoxes.Count)
            {
                p2 = junctionBoxes[p.p1].x * junctionBoxes[p.p2].x;
                break;
            }
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private double Distance(Point p1, Point p2)
    {
        var dx = p2.x - p1.x;
        var dy = p2.y - p1.y;
        var dz = p2.z - p1.z;
        return Math.Sqrt(dx * dx + dy * dy + dz * dz);
    }

    private static IEnumerable<(int p1, int p2)> Combinations(int count)
    {
        for (var i = 0; i < count; i++)
        {
            for (var j = i + 1; j < count; j++)
            {
                yield return (i, j);
            }
        }
    }
}
