namespace AoC2023;

public partial class Day11(ITestOutputHelper output) : AoCSolution<long, long, string[]>(output)
{
    const long SCALE = 1_000_000;

    protected override string[] LoadData() => LoadLinesFromFile("day11.txt");

    protected override (long p1, long p2) Solve()
    {
        var emptyRows = Data.Rows()
            .Enumerate()
            .Where(row => row.Value.All(c => c == '.'))
            .Select(row => row.Index)
            .ToList();
        var emptyColumns = Data.Columns()
            .Enumerate()
            .Where(row => row.Value.All(c => c == '.'))
            .Select(column => column.Index)
            .ToList();

        var points = Data
            .SelectMany((row, y) =>
                row.Enumerate()
                    .Where(c => c.Value == '#')
                    .Select(c => (X: c.Index, Y: y)))
            .ToList();

        var p1 = 0L;
        var p2 = 0L;
        foreach (var (point1, point2) in points.DifferentCombinations())
        {
            var minX = Math.Min(point1.X, point2.X);
            var maxX = Math.Max(point1.X, point2.X);
            var minY = Math.Min(point1.Y, point2.Y);
            var maxY = Math.Max(point1.Y, point2.Y);
            var manhattanDistance = maxX - minX + maxY - minY;

            var emptyRowsBetween = CountBetween(minY, maxY, emptyRows);
            var emptyColsBetween = CountBetween(minX, maxX, emptyColumns);

            p1 += manhattanDistance + emptyRowsBetween + emptyColsBetween;
            p2 += manhattanDistance + emptyRowsBetween * (SCALE - 1) + emptyColsBetween * (SCALE - 1);
        }

        return (p1, p2);
    }

    private long CountBetween(long min, long max, IList<int> vals)
    {
        var i = 0;
        var count = 0;
        while (i < vals.Count && vals[i] < min) i++;

        while (i < vals.Count && vals[i] < max)
        {
            i++;
            count++;
        }
        return count;
    }
}
