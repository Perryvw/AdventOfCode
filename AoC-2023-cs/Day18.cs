namespace AoC2023;

public partial class Day18(ITestOutputHelper output) : AoCSolution<int, long, List<(char Direction, int Distance, string Color)>>(output)
{
    protected override List<(char Direction, int Distance, string Color)> LoadData()
        => LoadLinesFromFile("day18.txt")
            .Select(l =>
            {
                var spl = l.Split(" ");
                return (spl[0][0], int.Parse(spl[1]), spl[2]);
            })
            .ToList();

    protected override (int p1, long p2) Solve()
    {
        var pos = (X: 0, Y: 0);
        var pos2 = (X: 0L, Y: 0L);

        var p1 = 2;
        var p2 = 2L;
        foreach (var (dir, distance, color) in Data)
        {
            var (dx, dy) = dir switch
            {
                'U' => (0, -1),
                'D' => (0, 1),
                'R' => (1, 0),
                'L' => (-1, 0),
                _ => throw new Exception("Not possible")
            };

            var newPos = (X: pos.X + dx * distance, Y: pos.Y + dy * distance);

            p1 += distance + (pos.X * newPos.Y) - (pos.Y * newPos.X);
            pos = newPos;

            var (distance2, direction2) = DecodeColor(color);
            var (dx2, dy2) = direction2 switch
            {
                '3' => (0, -1),
                '1' => (0, 1),
                '0' => (1, 0),
                '2' => (-1, 0),
                _ => throw new Exception("Not possible")
            };
            var newPos2 = (X: pos2.X + dx2 * distance2, Y: pos2.Y + dy2 * distance2);
            p2 += distance2 + (pos2.X * newPos2.Y) - (pos2.Y * newPos2.X);
            pos2 = newPos2;
        }

        return (p1/2, p2/2);
    }

    private (long distance, int direction) DecodeColor(string color)
    {
        long d = 0;
        for (int i = 2; i < 7; ++i)
        {
            var c = color[i] < 'a' ? color[i] - '0' : color[i] - 'a' + 10;
            d <<= 4;
            d += c;
        }
        return (d, color[7]);
    }
}
