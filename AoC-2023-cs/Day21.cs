namespace AoC2023;

using AoC2023.Util;
using System.Drawing;
using System.IO.Pipes;
using Coord = (long X, long Y);

public partial class Day21(ITestOutputHelper output) : AoCSolution<long, long, string[]>(output)
{
    protected override int Iterations => 100;

    protected override string[] LoadData() => LoadLinesFromFile("day21.txt");

    private int Width => Data[0].Length;
    private int Height => Data.Length;

    protected override (long p1, long p2) Solve()
    {
        var P1_STEPS = 64;
        var P2_STEPS = 26501365;

        var p2RequiredSteps = Width * 2 + P2_STEPS % Width;
        var seen = new Dictionary<Coord, int>();

        var q = new Queue<(Coord Pos, int Steps)>();
        q.Enqueue((FindStart(), 0));
        seen.Add(FindStart(), 0);

        while (q.TryDequeue(out var state))
        {
            if (state.Steps > p2RequiredSteps) continue;

            var right = state.Pos with { X = state.Pos.X + 1 };
            var left = state.Pos with { X = state.Pos.X - 1 };
            var top = state.Pos with { Y = state.Pos.Y - 1 };
            var bottom = state.Pos with { Y = state.Pos.Y + 1 };

            if (IsPlot(MathUtils.PosMod(right.X, Width), MathUtils.PosMod(right.Y, Height)) && seen.TryAdd(right, state.Steps + 1)) q.Enqueue((right, state.Steps + 1));
            if (IsPlot(MathUtils.PosMod(left.X, Width), MathUtils.PosMod(left.Y, Height)) && seen.TryAdd(left, state.Steps + 1)) q.Enqueue((left, state.Steps + 1));
            if (IsPlot(MathUtils.PosMod(top.X, Width), MathUtils.PosMod(top.Y, Height)) && seen.TryAdd(top, state.Steps + 1)) q.Enqueue((top, state.Steps + 1));
            if (IsPlot(MathUtils.PosMod(bottom.X, Width), MathUtils.PosMod(bottom.Y, Height)) && seen.TryAdd(bottom, state.Steps + 1)) q.Enqueue((bottom, state.Steps + 1));
        }

        long PositionsReachable(long steps) => seen.Values.Where(v => v <= steps && (v % 2) == (steps % 2)).Count();

        // P2 we can simply look up
        var p1 = PositionsReachable(P1_STEPS);

        // P2 we look at <<width>> intervals because the growth pattern repeats every Width-steps due to the empty first row and column
        // Then we reconstruct the parabola from 3 points
        var c0 = P2_STEPS % Width;
        var v0 = PositionsReachable(c0);
        var c1 = Width + P2_STEPS % Width;
        var v1 = PositionsReachable(c1);
        var c2 = 2 * Width + P2_STEPS % Width;
        var v2 = PositionsReachable(c2);

        // Brute force algebra because I'm dumb

        // p0 = c0 * c0, p1 = c0
        // p2 = c1 * c1, p3 = c1
        // p4 = c2 * c2, p5 = c2

        // e0: v0 = a * p0 + b * p1 + c
        // e1: v1 = a * p2 + b * p3 + c
        // e2: v2 = a * p4 + b * p5 + c

        // e0 - e1: (v0 - v1) = a * (p0 - p2) + b * (p1 - p3)
        // e1 - e2: (v1 - v2) = a * (p2 - p4) + b * (p3 - p5)

        // a = ( (v0 - v1) - b * (p1 - p3) ) / (p0 - p2)
        // a = (v0 - v1)/(p0 - p2) - b * (p1 - p3)/(p0 - p2) -> (v0 - v1)/(p0 - p2) = p6, (p1 - p3)/(p0 - p2) = p7
        // a = p6 - b * p7
        // (v1 - v2) = (p6 - b*p7) * (p2 - p4) + b * (p3 - p5)
        // (v1 - v2) = p6 * (p2 - p4) - b*p7 * (p2 - p4) + b * (p3 - p5)
        // (v1 - v2) = p6 * (p2 - p4) + b * (p3 - p5) - b*p7 * (p2 - p4)
        // (v1 - v2) = p6 * (p2 - p4) + b * ( (p3 - p5) - p7 * (p2 - p4) )
        // b = ( v1 - v2 - p6 * (p2 - p4) ) / ((p3 - p5) - p7 * (p2 - p4))

        var p_0 = c0 * c0;
        var p_1 = c0;
        var p_2 = c1 * c1;
        var p_3 = c1;
        var p_4 = c2 * c2;
        var p_5 = c2;

        var p_6 = (v0 - v1) / (double)(p_0 - p_2);
        var p_7 = (p_1 - p_3) / (double)(p_0 - p_2);

        var b = (v1 - v2 - p_6 * (p_2 - p_4)) / (double)((p_3 - p_5) - p_7 * (p_2 - p_4));
        var a = p_6 - b * p_7;
        var c = v0 - a * p_0 - b * p_1;

        // Now we reconstructed the parabola, simply calculate for the required nr of steps
        var p2 = a * P2_STEPS * P2_STEPS + b * P2_STEPS + c;

        return (p1, (long)p2);
    }

    private bool IsPlot(long x, long y)
        => Data[y][(int)x] != '#';

    private Coord FindStart()
    {
        for (var y = 0; y < Height; y++)
        {
            for (var x = 0; x < Width; x++)
            {
                if (Data[y][x] == 'S')
                    return (x, y);
            }
        }
        throw new Exception("No start found");
    }

    [Fact]
    public void TestPosMod()
    {
        Assert.Equal(9, MathUtils.PosMod(-1, 10));
        Assert.Equal(9, MathUtils.PosMod(-11, 10));
    }
}
