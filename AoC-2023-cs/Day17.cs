namespace AoC2023;

public partial class Day17(ITestOutputHelper output) : AoCSolution<int, int, int[][]>(output)
{
    protected override int Iterations => 30;

    enum Direction
    {
        Up,
        Down,
        Left,
        Right
    }

    record struct CrucibleState
    {
        public int X;
        public int Y;
        public int Cost;
        public Direction Direction;
    }

    protected override int[][] LoadData() => LoadLinesFromFile("day17.txt").Select(l => l.Select(c => c - '0').ToArray()).ToArray();

    protected override (int p1, int p2) Solve()
    {
        var p1 = FindOptimalPath(1, 3);
        var p2 = FindOptimalPath(4, 10);

        return (p1, p2);
    }

    private int FindOptimalPath(int minMoveDistance, int maxMoveDistance)
    {
        var goal = (X: Data[0].Length - 1, Y: Data.Length - 1);

        var q = new PriorityQueue<CrucibleState, int>();
        q.Enqueue(new CrucibleState
        {
            X = 0,
            Y = 0,
            Cost = 0,
            Direction = Direction.Up,
        }, 0);
        q.Enqueue(new CrucibleState
        {
            X = 0,
            Y = 0,
            Cost = 0,
            Direction = Direction.Left,
        }, 0);

        var seen = new HashSet<(int, int, int)>();

        var totalCost = 0;
        while (q.TryDequeue(out var state, out var cost))
        {
            if (state.X == goal.X && state.Y == goal.Y)
            {
                totalCost = state.Cost;
                break;
            }

            if (state.X > goal.X || state.X < 0 || state.Y > goal.Y || state.Y < 0) continue;

            if (!seen.Add((state.X, state.Y, (int)state.Direction))) continue;

            void EnqueueDirection(Direction direction)
            {
                var (dx, dy) = direction switch
                {
                    Direction.Up => (0, -1),
                    Direction.Down => (0, 1),
                    Direction.Left => (-1, 0),
                    Direction.Right => (1, 0),
                };

                var cost = 0;
                for (var i = 1; i <= maxMoveDistance; i++)
                {
                    var (x, y) = (state.X + dx * i, state.Y + dy * i);
                    if (x < 0 || y < 0 || x >= Data[0].Length || y >= Data.Length) break;

                    cost += Data[y][x];
                    if (i < minMoveDistance) continue;

                    q.Enqueue(new CrucibleState
                    {
                        X = x,
                        Y = y,
                        Direction = direction,
                        Cost = state.Cost + cost
                    }, state.Cost + cost);
                }
            }

            if (state.Direction == Direction.Up || state.Direction == Direction.Down)
            {
                EnqueueDirection(Direction.Left);
                EnqueueDirection(Direction.Right);
            }
            else
            {
                EnqueueDirection(Direction.Up);
                EnqueueDirection(Direction.Down);
            }
        }

        return totalCost;
    }
}
