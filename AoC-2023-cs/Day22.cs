namespace AoC2023;

public partial class Day22(ITestOutputHelper output) : AoCSolution<int, long, List<Day22.Brick>>(output)
{
    protected override int Iterations => 100;

    public record struct Coord3D(int X, int Y, int Z) { }

    public record Brick(Coord3D Min, Coord3D Max)
    {
        public int Width => Max.X - Min.X + 1;
        public int Depth => Max.Y - Min.Y + 1;
        public int Height => Max.Z - Min.Z + 1;

        public int Volume => Width * Depth * Height;
    }

    protected override List<Brick> LoadData()
        => LoadLinesFromFile("day22.txt")
            .Select(l =>
            {
                var spl = l.Split('~');
                var c1 = spl[0].Split(',');
                var c2 = spl[1].Split(',');
                return new Brick(
                    new Coord3D(int.Parse(c1[0]), int.Parse(c1[1]), int.Parse(c1[2])),
                    new Coord3D(int.Parse(c2[0]), int.Parse(c2[1]), int.Parse(c2[2]))
                );
            })
            .ToList();

    protected override (int p1, long p2) Solve()
    {
        Dictionary<Coord3D, Brick> coordsToBricks = new();
        Dictionary<Brick, List<Coord3D>> bricksToCoords = new();
        Dictionary<Brick, int> deltaZ = new();

        foreach (var brick in Data.OrderBy(b => b.Min.Z))
        {
            bricksToCoords[brick] = new List<Coord3D>();

            var xs = Enumerable.Range(brick.Min.X, brick.Max.X - brick.Min.X + 1);
            var ys = Enumerable.Range(brick.Min.Y, brick.Max.Y - brick.Min.Y + 1);

            var endZ = XYCoords(brick).Select(coord =>
            {
                var z = brick.Min.Z;
                for (; z > 1; z--)
                {
                    if (coordsToBricks.ContainsKey(new Coord3D(coord.X, coord.Y, z - 1)))
                    {
                        break;
                    }
                }
                return z;
            }).Max();

            deltaZ[brick] = brick.Min.Z - endZ;

            foreach (var x in xs)
            {
                foreach (var y in ys)
                {
                    for (var z = endZ; z < endZ + brick.Height; z++)
                    {
                        coordsToBricks[new Coord3D(x, y, z)] = brick;
                        bricksToCoords[brick].Add(new Coord3D(x, y, z));
                    }
                }
            }
        }

        // Assert volume hasn't changed
        Assert.Equal(Data.Select(b => b.Volume).Sum(), coordsToBricks.Count);

        Dictionary<Brick, List<Brick>> bricksAbove = Data.ToDictionary(b => b, _ => new List<Brick>());
        Dictionary<Brick, List<Brick>> bricksBelow = Data.ToDictionary(b => b, _ => new List<Brick>());

        foreach (var brick in Data)
        {
            bricksAbove[brick].AddRange(CoordsAbove(brick)
                .Select(coord => coord with { Z = coord.Z - deltaZ[brick] })
                .Where(coordsToBricks.ContainsKey)
                .Select(coord => coordsToBricks[coord])
                .Distinct());

            bricksBelow[brick].AddRange(CoordsBelow(brick)
                    .Select(coord => coord with { Z = coord.Z - deltaZ[brick] })
                    .Where(coordsToBricks.ContainsKey)
                    .Select(coord => coordsToBricks[coord])
                    .Distinct());
        }

        var p1 = Data.Where(brick => bricksAbove[brick].All(brickAbove => bricksBelow[brickAbove].Count > 1)).Count();

        long CalcP2(Brick brick)
        {
            HashSet<Brick> removed = [brick];
            Queue<Brick> q = new Queue<Brick>();
            foreach (var bricksAbove in bricksAbove[brick]) q.Enqueue(bricksAbove);

            while (q.TryDequeue(out var b))
            {
                if (bricksBelow[b].All(removed.Contains))
                {
                    removed.Add(b);
                    foreach (var brickAbove in bricksAbove[b])
                    {
                        q.Enqueue(brickAbove);
                    }
                }
            }

            return removed.Count - 1;
        }

        var p2 = Data.Select(CalcP2).Sum();

        return (p1, p2);
    }

    private IEnumerable<Coord3D> XYCoords(Brick brick)
        => Enumerable.Range(brick.Min.X, brick.Width)
            .SelectMany(x => Enumerable.Range(brick.Min.Y, brick.Depth)
                .Select(y => new Coord3D(x, y, brick.Min.Z)));

    private IEnumerable<Coord3D> CoordsBelow(Brick brick)
        => XYCoords(brick).Select(coord => coord with { Z = coord.Z - 1 });

    private IEnumerable<Coord3D> CoordsAbove(Brick brick)
        => XYCoords(brick).Select(coord => coord with { Z = coord.Z + brick.Height });

    [Fact]
    public void TestCoordsAbove()
    {
        Assert.Equal(
            [new Coord3D(0, 0, 2), new Coord3D(0, 1, 2), new Coord3D(1, 0, 2), new Coord3D(1, 1, 2)], 
            CoordsAbove(new Brick(new Coord3D(0, 0, 0), new Coord3D(1, 1, 1))).ToList());
    }
}
