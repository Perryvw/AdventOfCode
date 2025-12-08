using AoC_2025_cs.Common;

namespace AoC_2025_cs;

public class Day7
{
    [Fact]
    public async Task P1P2()
    {
        var p1 = 0;
        long p2 = 0;

        var grid = new Grid(await File.ReadAllTextAsync("../../../data/day7.txt", TestContext.Current.CancellationToken));

        Dictionary<int, long> currentBeams = [];
        Dictionary<int, long> nextBeams = [];

        for (var x = 0; x < grid.Width; x++)
        {
            if (grid.Contains(x, 0, 'S'))
            {
                currentBeams.Add(x, 1);
                break;
            }
        }

        for (var y = 1; y < grid.Height; y++)
        {
            foreach (var (beam, count) in currentBeams)
            {
                if (grid.Contains(beam, y, '^'))
                {
                    void AddBeams(int x)
                    {
                        if (nextBeams.TryGetValue(x, out var v))
                        {
                            nextBeams[x] = v + count;
                        }
                        else
                        {
                            nextBeams.Add(x, count);
                        }
                    }
                    AddBeams(beam - 1);
                    AddBeams(beam + 1);
                }
                else
                {
                    if (nextBeams.TryGetValue(beam, out var v))
                    {
                        nextBeams[beam] = v + count;
                    }
                    else
                    {
                        nextBeams.Add(beam, count);
                    }
                }
            }
            currentBeams = nextBeams;
            nextBeams = [];
        }
        p1 = currentBeams.Count;
        p2 = currentBeams.Select(kvp => kvp.Value).Sum();

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
