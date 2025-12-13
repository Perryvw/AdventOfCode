using AoC_2025_cs.Common;

namespace AoC_2025_cs;

using Point = (long x, long y);
using Rectangle = ((long x, long y) p1, (long x, long y) p2);

public class Day9
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var lines = await File.ReadAllLinesAsync("../../../data/day9.txt", TestContext.Current.CancellationToken);
        var tiles = lines.Select(l =>
        {
            var spl = l.Split(",");
            return (x: long.Parse(spl[0]), y: long.Parse(spl[1]));
        }).ToList();

        HashSet<Rectangle> rectangles = [];
        for (var i = 0; i < tiles.Count; i++)
        {
            for (var j = i + 1; j < tiles.Count; j++)
            {
                rectangles.Add((tiles[i], tiles[j]));
            }
        }

        p1 = rectangles.Select(Size).Max();

        HashSet<Rectangle> edges = [];
        for (var i = 0; i < tiles.Count; i++)
        {
            edges.Add((tiles[i], tiles[i < tiles.Count - 1 ? i + 1 : 0]));
        }

        foreach (var rectangle in rectangles)
        {
            var inner = Shrink(rectangle);
            if (edges.Any(e => Overlaps(e, inner)))
            {
                rectangles.Remove(rectangle);
            }
        }

        p2 = rectangles.Select(Size).Max();

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private static long Size(Rectangle rect) => (Right(rect) - Left(rect) + 1) * (Bottom(rect) - Top(rect) + 1);

    private static bool Overlaps(Rectangle r1, Rectangle r2)
    {
        return Top(r1) <= Bottom(r2) && Bottom(r1) >= Top(r2) && Left(r1) <= Right(r2) && Right(r1) >= Left(r2);
    }

    private static Rectangle Shrink(Rectangle r)
    {
        return ((Left(r) + 1, Top(r) + 1), (Right(r) - 1, Bottom(r) - 1));
    }

    private static long Left(Rectangle r) => r.p1.x < r.p2.x ? r.p1.x : r.p2.x;
    private static long Right(Rectangle r) => r.p1.x > r.p2.x ? r.p1.x : r.p2.x;
    private static long Top(Rectangle r) => r.p1.y < r.p2.y ? r.p1.y : r.p2.y;
    private static long Bottom(Rectangle r) => r.p1.y > r.p2.y ? r.p1.y : r.p2.y;
}
