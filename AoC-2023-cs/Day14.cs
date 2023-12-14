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
        var p1 = Score(TiltNorth(Data));

        var p2 = 0;
        var p2Grid = Data;
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

    private Grid SpinCycle(Grid g)
        => TiltEast(TiltSouth(TiltWest(TiltNorth(g))));

    private Grid TiltNorth(Grid grid)
    {
        var newGrid = grid.Select(r => r.ToArray()).ToArray();

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
                            newGrid[y][x] = '.';
                            newGrid[yNew + offset + 1][x] = 'O';
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

        return newGrid;
    }

    private Grid TiltSouth(Grid grid)
    {
        var newGrid = grid.Select(r => r.ToArray()).ToArray();

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
                            newGrid[y][x] = '.';
                            newGrid[yNew - offset - 1][x] = 'O';
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

        return newGrid;
    }

    private Grid TiltWest(Grid grid)
    {
        var newGrid = grid.Select(r => r.ToArray()).ToArray();

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
                            newGrid[y][x] = '.';
                            newGrid[y][xNew + offset + 1] = 'O';
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

        return newGrid;
    }

    private Grid TiltEast(Grid grid)
    {
        var newGrid = grid.Select(r => r.ToArray()).ToArray();

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
                            newGrid[y][x] = '.';
                            newGrid[y][xNew - offset - 1] = 'O';
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

        return newGrid;
    }

    private int Score(Grid grid)
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

    private string StringHash(Grid grid)
    {
        var sb = new StringBuilder();
        foreach (var l in grid) {
            sb.Append(l);
        }
        return sb.ToString();
    }
}
