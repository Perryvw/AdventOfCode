using System.Formats.Asn1;
using AoC_2025_cs.Common;

namespace AoC_2025_cs;

public class Day12
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var text = await File.ReadAllTextAsync("../../../data/day12.txt", TestContext.Current.CancellationToken);
        var blocks = text.Split("\n\n");

        List<int> area = [];
        for (var i = 0; i < blocks.Length - 1; i++)
        {
            area.Add(blocks[i].Count(c => c == '#'));
        }

        foreach (var line in blocks.Last().Split("\n"))
        {
            var spl = line.Split(' ');
            var splArea = spl[0].Split('x');
            var totalArea = long.Parse(splArea[0]) * long.Parse(splArea[1][..^1]);

            long presentArea = 0;
            for (var i = 1; i < spl.Length; i++)
            {
                var numPresents = long.Parse(spl[i]);
                presentArea += numPresents * area[i - 1];
            }

            if (presentArea <= totalArea)
            {
                p1++;
            }
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
