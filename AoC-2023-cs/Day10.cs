using System.Text;

namespace AoC2023;

public partial class Day10(ITestOutputHelper output) : AoCSolution<int, int, string[]>(output)
{
    protected override string[] LoadData() => LoadLinesFromFile("day10.txt");

    protected override (int p1, int p2) Solve()
    {
        var startingPos = FindStart();
        var loopCells = new HashSet<(int, int)>();

        var steps = StepsThroughPipe(startingPos.X, startingPos.Y, loopCells);

        var p1 = steps / 2;

        var p2 = CountInside(loopCells);

        return (p1, p2);
    }

    private (int X, int Y) FindStart()
    {
        for (var y = 0; y < Data.Length; y++)
        {
            for (var x = 0; x < Data[y].Length; x++)
            {
                if (Data[y][x] == 'S')
                {
                    return (x, y);
                }
            }
        }
        throw new InvalidDataException("No starting point found");
    }

    private int StepsThroughPipe(int startX, int startY, ICollection<(int, int)> loopCells)
    {
        var steps = 0;
        var prevPos = (X: startX, Y: startY);
        var pos = Next(startX, startY, 0, 0);
        loopCells.Add(pos);
        loopCells.Add(prevPos);
        steps++;
        while (Data[pos.Y][pos.X] != 'S')
        {
            var newPos = Next(pos.X, pos.Y, prevPos.X, prevPos.Y);
            prevPos = pos;
            pos = newPos;
            steps++;
            loopCells.Add(pos);
        }

        return steps;
    }

    private (int X, int Y) Next(int x, int y, int prevX, int prevY)
    {
        var current = Data[y][x];
        return current switch
        {
            'S' => FindFirstPipe(x, y),
            '|' when prevY < y => (x, y + 1),
            '|' when prevY > y => (x, y - 1),
            '-' when prevX < x => (x + 1, y),
            '-' when prevX > x => (x - 1, y),
            'L' when prevY < y => (x + 1, y),
            'L' when prevY == y => (x, y - 1),
            'J' when prevY < y => (x - 1, y),
            'J' when prevY == y => (x, y - 1),
            '7' when prevY > y => (x - 1, y),
            '7' when prevY == y => (x, y + 1),
            'F' when prevY > y => (x + 1, y),
            'F' when prevY == y => (x, y + 1),
            _ => throw new InvalidOperationException("unexpected!")
        }; ;
    }

    private (int X, int Y) FindFirstPipe(int x, int y)
    {
        if (Data[y][x + 1] == '-' || Data[y][x + 1] == 'J' || Data[y][x + 1] == '7')
        {
            return (x + 1, y);
        }
        else if (Data[y][x - 1] == '-' || Data[y][x - 1] == 'F' || Data[y][x - 1] == 'L')
        {
            return (x - 1, y);
        }
        else if (Data[y + 1][x] == '|' || Data[y + 1][x] == 'J' || Data[y + 1][x] == 'L')
        {
            return (x, y + 1);
        }
        else if (Data[y - 1][x] == '|' || Data[y + 1][x] == 'F' || Data[y + 1][x] == '7')
        {
            return (x, y - 1);
        }
        else
        {
            throw new InvalidDataException("Could not find opening");
        }
    }

    private int CountInside(ICollection<(int X, int Y)> loopCells)
    {
        // Count inside by raycasting from the left and switching inside/outside every time we cross a pipe border
#if DEBUG
        var sb = new StringBuilder();
        sb.AppendLine("<html><body><code>");
#endif

        var p2 = 0;
        for (var y = 0; y < Data.Length; y++)
        {
            var inside = false;
            var entry = '|';
            for (var x = 0; x < Data[y].Length; x++)
            {
                var current = Data[y][x];
                if (loopCells.Contains((x, y)))
                {
                    if (current == 'S')
                    {
                        var left = Data[y][x - 1];
                        var right = Data[y][x + 1];
                        var up = Data[y - 1][x];
                        var down = Data[y + 1][x];

                        current = StartingShape(left, right, up, down);
                    }

                    if (current == '|')
                    {
                        inside = !inside;
                    }
                    if (current == 'F' || current == 'L')
                    {
                        entry = current;
                    }
                    if (current == '7' && entry == 'L')
                    {
                        inside = !inside;
                    }
                    if (current == 'J' && entry == 'F')
                    {
                        inside = !inside;
                    }

#if DEBUG
                    sb.Append($"<font color='blue'><b>{current}</b></font>");
#endif
                }
                else if (inside)
                {
                    p2++;
#if DEBUG
                    sb.Append($"<font color='red'><b>.</b></font>");
#endif
                }
#if DEBUG
                else
                {
                    sb.Append(current);
                }
#endif
            }
#if DEBUG
            sb.AppendLine("<br>");
#endif
        }

#if DEBUG
        sb.AppendLine("</code></body></html>");
        File.WriteAllText("out.html", sb.ToString());
#endif

        return p2;
    }

    private char StartingShape(char left, char right, char up, char down)
    {
        var upConnects = up == '|' || up == '7' || up == 'F';
        var downConnects = down == '|' || down == 'J' || down == 'L';
        var leftConnects = left == '-' || left == 'L' || left == 'F';
        var rightConnects = right == '-' || right == '7' || right == 'J';

        if (upConnects && downConnects) return '|';
        else if (leftConnects && rightConnects) return '-';
        else if (upConnects && leftConnects) return 'J';
        else if (upConnects && rightConnects) return 'L';
        else if (downConnects && leftConnects) return '7';
        else if (downConnects && rightConnects) return 'F';

        throw new Exception("unexpected");
    }
}
