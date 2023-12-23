namespace AoC2023;

public partial class Day23(ITestOutputHelper output) : AoCSolution<long, long, string[]>(output)
{
    protected override int Iterations => 1;
    private record struct Coord(int X, int Y)
    {
        public readonly Coord Left => new(X - 1, Y);
        public readonly Coord Right => new(X + 1, Y);
        public readonly Coord Up => new(X, Y - 1);
        public readonly Coord Down => new(X, Y + 1);

        public readonly IEnumerable<Coord> Around => [Up, Right, Down, Left];

        public override string ToString() => $"({X}, {Y})";
    }

    protected override string[] LoadData() => LoadLinesFromFile("day23.txt");

    private int Width => Data[0].Length;
    private int Height => Data.Length;

    private char Tile(Coord c) => Data[c.Y][c.X];

    private bool IsPath(Coord c) => c.X < 0 || c.X >= Width || c.Y < 0 || c.Y >= Height ? false : Data[c.Y][c.X] != '#';

    private bool CanGoToFrom(Coord c, Coord from) => IsPath(c)
        && (from.X < c.X || Tile(c) != '>')
        && (from.X > c.X || Tile(c) != '<')
        && (from.Y < c.Y || Tile(c) != 'v')
        && (from.Y > c.Y || Tile(c) != '^');

    protected override (long p1, long p2) Solve()
    {
        var TARGET_POS = new Coord(Width - 2, Height - 1);

        int? LongestPathFrom(Coord pos, HashSet<Coord> seen)
        {
            var length = 0;

            while (true)
            {
                seen.Add(pos);

                var possibilities = pos.Around.Where(p => CanGoToFrom(p, pos) && !seen.Contains(p)).ToList();
                if (possibilities.Count == 0) return null;
                if (possibilities.Count == 1)
                {
                    pos = possibilities[0];
                    length++;
                    if (pos == TARGET_POS) return length;
                }
                else
                {
                    var nextResults = possibilities
                        .Select(p => (p, LongestPathFrom(p, seen.ToHashSet())))
                        .Where(l => l.Item2.HasValue)
                        .ToList();

                    if (nextResults.Any()) return length + 1 + nextResults.MaxBy(t => t.Item2).Item2;
                    else return null;
                }
            }
        }

        var p1 = LongestPathFrom(new Coord(1, 0), new HashSet<Coord>())!.Value;

        var edgeList = new Dictionary<Coord, List<(Coord To, int Distance)>>();
        edgeList[new Coord(1, 0)] = new();

        void LongestPathFrom2(Coord pos, Coord from)
        {
            HashSet<Coord> seen = [];
            var length = 0;

            while (true)
            {
                seen.Add(pos);

                var possibilities = pos.Around.Where(p => IsPath(p)).ToList();

                if (possibilities.Count == 1)
                {
                    pos = possibilities[0];
                    length++;
                }
                else if (possibilities.Count == 2)
                {
                    var next = possibilities.Where(p => !seen.Contains(p) && p != from).ToList();
                    Assert.True(next.Count < 2);
                    if (next.Any())
                    {
                        pos = next[0];
                        length++;
                        if (pos == TARGET_POS)
                        {
                            edgeList[from].Add((pos, length));
                            edgeList.TryAdd(pos, new());
                            edgeList[pos].Add((from, length));
                            return;
                        }
                    }
                    else
                    {
                        return;
                    }
                }
                else
                {
                    edgeList[from].Add((pos, length + 1));
                    if (!edgeList.TryAdd(pos, new())) return;
                    edgeList[pos].Add((from, length + 1));

                    foreach (var p in possibilities
                        .Where(p => !seen.Contains(p)))
                    {
                        LongestPathFrom2(p, pos);
                    }
                    return;
                }
            }
        }

        LongestPathFrom2(new Coord(1, 0), new Coord(1, 0));

        int? LongestPathFrom3(Coord pos, HashSet<Coord> seen)
        {
            if (pos == TARGET_POS) return 0;
            seen.Add(pos);
            var connections = edgeList[pos];
            var nexts = edgeList[pos]
                .Where(t => !seen.Contains(t.To))
                .Select(t => t.Distance + LongestPathFrom3(t.To, seen.ToHashSet()))
                .Where(r => r.HasValue)
                .ToList();

            return nexts.Any() ? nexts.Max() : null;
        }

        var p2 = LongestPathFrom3(new Coord(1, 0), new()).Value;

        return (p1, p2);
    }
}
