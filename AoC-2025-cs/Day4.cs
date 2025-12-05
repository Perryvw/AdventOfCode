using AoC_2025_cs.Common;

namespace AoC_2025_cs;

public class Day4
{
    [Fact]
    public async Task P1P2()
    {
        var p1 = 0;
        var p2 = 0;

        var grid = new Grid(await File.ReadAllTextAsync("../../../data/day4.txt", TestContext.Current.CancellationToken));

        for (var y = 0; y < grid.Height; y++)
        {
            for (var x = 0; x < grid.Width; x++)
            {
                if (grid.Contains(x, y, '@'))
                {
                    var count = Grid.CellsAround(x, y).Count(p => grid.Contains(p.x, p.y, '@'));
                    if (count < 4)
                    {
                        p1++;
                    }
                }
            }
        }

        bool removed = true;
        while (removed)
        {
            removed = false;

            for (var y = 0; y < grid.Height; y++)
            {
                for (var x = 0; x < grid.Width; x++)
                {
                    if (grid.Contains(x, y, '@'))
                    {
                        var count = Grid.CellsAround(x, y).Count(p => grid.Contains(p.x, p.y, '@'));
                        if (count < 4)
                        {
                            removed = true;
                            grid.Set(x, y, '.');
                            p2++;
                        }
                    }
                }
            }
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
