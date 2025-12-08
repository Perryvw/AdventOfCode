using System.Text;

namespace AoC_2025_cs.Common;

class Grid
{
    public int Width;
    public int Height;

    private char[] _data;

    public Grid(string data)
    {
        _data = [.. data];
        Width = data.IndexOf('\n');
        // Account for newlines
        Height = (data.Length + 1) / (Width + 1);
    }

    public char At(int x, int y) => _data[Index(x, y)];

    public void Set(int x, int y, char c)
    {
        _data[Index(x, y)] = c;
    }

    public bool Contains(int x, int y, char v)
    {
        if (x < 0 || x >= Width) return false;
        if (y < 0 || y >= Height) return false;

        return _data[Index(x, y)] == v;
    }

    public override string ToString()
    {
        var sb = new StringBuilder();

        for (var y = 0; y < Height; y++)
        {
            for (var x = 0; x < Width; x++)
            {
                sb.Append(At(x, y));
            }
            sb.AppendLine();
        }

        return sb.ToString();
    }

    private int Index(int x, int y) => y * Width + y + x;

    public static IEnumerable<(int x, int y)> CellsAround(int x, int y)
    {
        yield return (x, y - 1);
        yield return (x + 1, y - 1);
        yield return (x + 1, y);
        yield return (x + 1, y + 1);
        yield return (x, y + 1);
        yield return (x - 1, y + 1);
        yield return (x - 1, y);
        yield return (x- 1, y - 1);
    }
}