namespace AoC2023;

using PosDir = (int X, int Y, int dX, int dY);

public partial class Day16(ITestOutputHelper output) : AoCSolution<int, int, string[]>(output)
{
    protected override int Iterations => 30;

    protected override string[] LoadData() => LoadLinesFromFile("day16.txt");

    protected override (int p1, int p2) Solve()
    {
        var p1 = Energized((0, 0, 1, 0));

        var p2 = Enumerable.Range(0, Width).AsParallel().Select(x => (x, 0, 0, 1)).Select(posDir => (PosDir: posDir, Value: Energized(posDir)))
            .Concat(Enumerable.Range(0, Width).AsParallel().Select(x => (x, Height - 1, 0, -1)).Select(posDir => (PosDir: posDir, Value: Energized(posDir))))
            .Concat(Enumerable.Range(0, Height).AsParallel().Select(y => (0, y, 1, 0)).Select(posDir => (PosDir: posDir, Value: Energized(posDir))))
            .Concat(Enumerable.Range(0, Height).AsParallel().Select(y => (Width - 1, y, -1, 0)).Select(posDir => (PosDir: posDir, Value: Energized(posDir))))
            .MaxBy(result => result.Value);

        return (p1, p2.Value);
    }

    private int Height => Data.Length;
    private int Width => Data[0].Length;

    public int Energized(PosDir startingPoint)
    {
        Stack<PosDir> s = new();
        s.Push(startingPoint);

        var seen = new HashSet<PosDir>();
        var energized = new HashSet<(int, int)>();

        while (s.TryPop(out var posDir))
        {
            if (posDir.X < 0 || posDir.X >= Width || posDir.Y < 0 || posDir.Y >= Height) continue;
            if (seen.Contains(posDir)) continue;

            var tile = Data[posDir.Y][posDir.X];
            if (tile == '.')
            {
                s.Push((posDir.X + posDir.dX, posDir.Y + posDir.dY, posDir.dX, posDir.dY));
            }
            else if (tile == '\\')
            {
                var newDir = (dX: posDir.dY, dY: posDir.dX);
                s.Push((posDir.X + newDir.dX, posDir.Y + newDir.dY, newDir.dX, newDir.dY));
            }
            else if (tile == '/')
            {
                var newDir = (dX: -posDir.dY, dY: -posDir.dX);
                s.Push((posDir.X + newDir.dX, posDir.Y + newDir.dY, newDir.dX, newDir.dY));
            }
            else if (tile == '|')
            {
                if (posDir.dY == 0)
                {
                    s.Push((posDir.X, posDir.Y + 1, 0, 1));
                    s.Push((posDir.X, posDir.Y - 1, 0, -1));
                }
                else
                {
                    // pointy end, ignore
                    s.Push((posDir.X + posDir.dX, posDir.Y + posDir.dY, posDir.dX, posDir.dY));
                }
            }
            else if (tile == '-')
            {
                if (posDir.dX == 0)
                {
                    s.Push((posDir.X - 1, posDir.Y, -1, 0));
                    s.Push((posDir.X + 1, posDir.Y, 1, 0));
                }
                else
                {
                    // pointy end, ignore
                    s.Push((posDir.X + posDir.dX, posDir.Y + posDir.dY, posDir.dX, posDir.dY));
                }
            }
            else
            {
                throw new Exception("should not happen");
            }

            seen.Add(posDir);
            energized.Add((posDir.X, posDir.Y));
        }

        return energized.Count;
    }
}
