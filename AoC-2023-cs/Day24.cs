using Z3 = Microsoft.Z3;

namespace AoC2023;

public partial class Day24(ITestOutputHelper output) : AoCSolution<long, long, List<Day24.HailStone>>(output)
{
    protected override int Iterations => 1;

    public record struct Coord2D(long X, long Y) { }
    public record struct Coord3D(long X, long Y, long Z)
    {
        public readonly Coord2D XY => new(X, Y);
    }
    public record struct HailStone(Coord3D Position, Coord3D Velocity) { }

    protected override List<HailStone> LoadData()
        => LoadLinesFromFile("day24.txt").Select(l =>
        {
            var spl = l.Split(" @ ");
            var pos = spl[0].Split(", ").Select(long.Parse).ToArray();
            var vel = spl[1].Split(", ").Select(long.Parse).ToArray();

            return new HailStone(
                new Coord3D(pos[0], pos[1], pos[2]),
                new Coord3D(vel[0], vel[1], vel[2])
            );

        }).ToList();

    const long P1_MIN_POS = 200000000000000L;
    const long P1_MAX_POS = 400000000000000L;

    protected override (long p1, long p2) Solve()
    {
        var p1 = Data
            .DifferentCombinations()
            .Select(c => Intersection2D(c.Item1, c.Item2))
            .Where(i => i.HasValue && IsInArea(i.Value, P1_MIN_POS, P1_MAX_POS))
            .Count();

        var p2 = Z3SolveP2();

        return (p1, p2);
    }

    private static Coord2D? Intersection2D(HailStone s1, HailStone s2)
    {
        // Reduce to lines of standard formula y = ax + b
        var a1 = s1.Velocity.Y / (double)s1.Velocity.X;
        var a2 = s2.Velocity.Y / (double)s2.Velocity.X;

        if (a1 == a2) return null; // parallel lines

        var b1 = s1.Position.Y - a1 * s1.Position.X;
        var b2 = s2.Position.Y - a2 * s2.Position.X;

        // Lines intersect at some (x_i, y_i)
        // y_i = a1 * x_i + b1
        // y_i = a2 * x_i + b2
        // x_i = (b2 - b1) / (a1 - a2)
        var xi = (b2 - b1) / (a1 - a2);
        var yi = a1 * xi + b1;

        // xi = v1.x * t + p1.x
        // t = (xi - p1.x) / v1.x
        var inFuture = (((xi - s1.Position.X) / (double)s1.Velocity.X) > 0) && ((xi - s2.Position.X) / (double)s2.Velocity.X) > 0;
        if (!inFuture) return null;

        return new Coord2D((long)xi, (long)yi);
    }

    private static bool IsInArea(Coord2D coord, long min, long max)
        => coord.X >= min && coord.Y >= min && coord.X <= max && coord.Y <= max;

    private long Z3SolveP2()
    {
        using var z3ctx = new Z3.Context();

        var x = z3ctx.MkIntConst("x");
        var y = z3ctx.MkIntConst("y");
        var z = z3ctx.MkIntConst("z");

        var vx = z3ctx.MkIntConst("vx");
        var vy = z3ctx.MkIntConst("vy");
        var vz = z3ctx.MkIntConst("vz");

        var solver = z3ctx.MkSolver();

        foreach (var (i, hail) in Data.Enumerate())
        {
            var ti = z3ctx.MkIntConst($"t{i}");

            var xiExpr = (ti * z3ctx.MkInt(hail.Velocity.X)) + z3ctx.MkInt(hail.Position.X);
            var yiExpr = (ti * z3ctx.MkInt(hail.Velocity.Y)) + z3ctx.MkInt(hail.Position.Y);
            var ziExpr = (ti * z3ctx.MkInt(hail.Velocity.Z)) + z3ctx.MkInt(hail.Position.Z);

            solver.Assert(z3ctx.MkEq(xiExpr, (ti * vx) + x));
            solver.Assert(z3ctx.MkEq(yiExpr, (ti * vy) + y));
            solver.Assert(z3ctx.MkEq(ziExpr, (ti * vz) + z));
        }

        var sat = solver.Check();
        return (solver.Model.Evaluate(x + y + z) as Z3.IntNum)!.Int64;
    }

    [Fact]
    public void TestVelocity2()
    {
        Assert.Null(Intersection2D(
            new HailStone(new Coord3D(18, 19, 22), new Coord3D(-1, -1, -2)),
            new HailStone(new Coord3D(20, 19, 15), new Coord3D(1, -5, -3))));
    }
}
