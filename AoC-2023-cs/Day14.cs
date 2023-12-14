namespace AoC2023;

using System.Text;
using Grid = char[][];

public partial class Day14(ITestOutputHelper output) : AoCSolution<int, int, Grid>(output)
{
    protected override int Iterations => 100;

    const long P2_REPETITIONS = 1_000_000_000;

    protected override Grid LoadData() => LoadLinesFromFile("day14.txt").Select(s => s.ToCharArray()).ToArray();

    protected override (int p1, int p2) Solve()
    {
        var inpCopy = Data.Select(s => s.ToArray()).ToArray();

        var p1 = Score(TiltNorth(inpCopy));

        var p2 = 0;
        var p2Grid = inpCopy;
        var cache = new Dictionary<string, long>();
        var scores = new Dictionary<long, int>();
        for (long i = 1; i <= P2_REPETITIONS; i++)
        {
            p2Grid = SpinCycle(p2Grid);
            var hash = StringHash(p2Grid);

            if (cache.TryGetValue(hash, out var seenAtStep))
            {
                var lead = seenAtStep;
                var cycle = i - seenAtStep;
                var left = (P2_REPETITIONS - lead) % cycle;

                //LogOutput($"{lead} / {cycle}");

                p2 = scores[seenAtStep + left];
                break;
            }
            else
            {
                cache[hash] = i;
                scores[i] = Score(p2Grid);
            }
        }

        return (p1, p2);
    }

    private static Grid SpinCycle(Grid g)
        => TiltEast(TiltSouth(TiltWest(TiltNorth(g))));

    private static Grid TiltNorth(Grid grid)
    {
        var width = grid[0].Length;
        for (var x = 0; x < width; x++)
        {
            for (var y = 0; y < grid.Length; y++)
            {
                if (grid[y][x] == 'O')
                {
                    var offset = 0;
                    for (var yNew = y - 1; ; yNew--)
                    {
                        if (yNew < 0 || grid[yNew][x] == '#')
                        {
                            grid[y][x] = '.';
                            grid[yNew + offset + 1][x] = 'O';
                            break;
                        }
                        else if (grid[yNew][x] == 'O')
                        {
                            offset++;
                        }
                    }
                }
            }
        }

        return grid;
    }

    private static Grid TiltSouth(Grid grid)
    {
        var width = grid[0].Length;
        for (var x = 0; x < width; x++)
        {
            for (var y = grid.Length - 1; y >= 0; y--)
            {
                if (grid[y][x] == 'O')
                {
                    var offset = 0;
                    for (var yNew = y + 1; ; yNew++)
                    {
                        if (yNew >= grid.Length || grid[yNew][x] == '#')
                        {
                            grid[y][x] = '.';
                            grid[yNew - offset - 1][x] = 'O';
                            break;
                        }
                        else if (grid[yNew][x] == 'O')
                        {
                            offset++;
                        }
                    }
                }
            }
        }

        return grid;
    }

    private static Grid TiltWest(Grid grid)
    {
        var width = grid[0].Length;
        for (var y = 0; y < width; y++)
        {
            for (var x = 0; x < grid.Length; x++)
            {
                if (grid[y][x] == 'O')
                {
                    var offset = 0;
                    for (var xNew = x - 1; ; xNew--)
                    {
                        if (xNew < 0 || grid[y][xNew] == '#')
                        {
                            grid[y][x] = '.';
                            grid[y][xNew + offset + 1] = 'O';
                            break;
                        }
                        else if (grid[y][xNew] == 'O')
                        {
                            offset++;
                        }
                    }
                }
            }
        }

        return grid;
    }

    private static Grid TiltEast(Grid grid)
    {
        var width = grid[0].Length;
        for (var y = 0; y < width; y++)
        {
            for (var x = width - 1; x >= 0; x--)
            {
                if (grid[y][x] == 'O')
                {
                    var offset = 0;
                    for (var xNew = x + 1; ; xNew++)
                    {
                        if (xNew >= width || grid[y][xNew] == '#')
                        {
                            grid[y][x] = '.';
                            grid[y][xNew - offset - 1] = 'O';
                            break;
                        }
                        else if (grid[y][xNew] == 'O')
                        {
                            offset++;
                        }
                    }
                }
            }
        }

        return grid;
    }

    private static int Score(Grid grid)
    {
        var total = 0;
        for (var y = 0; y < grid.Length; y++)
        {
            var score = grid.Length - y;
            for (var x = 0; x < grid[0].Length; x++)
            {
                if (grid[y][x] == 'O') total += score;
            }
        }
        return total;
    }

    private static string StringHash(Grid grid)
    {
        var sb = new StringBuilder();
        foreach (var l in grid)
        {
            sb.Append(l);
        }
        return sb.ToString();
    }
}
