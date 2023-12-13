namespace AoC2023;

public partial class Day13(ITestOutputHelper output) : AoCSolution<int, int, string[][]>(output)
{
    protected override string[][] LoadData() => LoadLineBlocksFromFile("day13.txt");

    protected override (int p1, int p2) Solve()
    {
        var p1 = Data.Select(block =>
            {
                var height = block.Length;
                var width = block[0].Length;

                var reflectionRow = Enumerable.Range(0, height - 1)
                    .Cast<Nullable<int>>()
                    .Where(i => ReflectionErrorHorizontal(block, i.Value) == 0)
                    .FirstOrDefault();

                var reflectionColumn = Enumerable.Range(0, width - 1)
                    .Cast<Nullable<int>>()
                    .Where(i => ReflectionErrorVertical(block, i.Value) == 0)
                    .FirstOrDefault();

                return reflectionRow.HasValue ? 100 * (reflectionRow.Value + 1) : reflectionColumn.Value + 1;
            })
            .Sum();

        var p2 = Data.Select(block =>
            {
                var height = block.Length;
                var width = block[0].Length;

                var reflectionRow = Enumerable.Range(0, height - 1)
                    .Cast<Nullable<int>>()
                    .Where(i => ReflectionErrorHorizontal(block, i.Value) == 1)
                    .FirstOrDefault();

                var reflectionColumn = Enumerable.Range(0, width - 1)
                    .Cast<Nullable<int>>()
                    .Where(i => ReflectionErrorVertical(block, i.Value) == 1)
                    .FirstOrDefault();

                return reflectionRow.HasValue ? 100 * (reflectionRow.Value + 1) : reflectionColumn.Value + 1;
            })
            .Sum();

        return (p1, p2);
    }

    private static int Reflect(int value, int around)
    {
        return around + (around - value);
    }

    private static int ReflectionErrorHorizontal(string[] block, int row)
    {
        var error = 0;
        for (var y = 0; y < block.Length; y++)
        {
            var otherI = Reflect(y, row) + 1;
            if (otherI < y || otherI < 0 || otherI >= block.Length) continue;
            for (var x = 0; x < block[y].Length; x++)
            {
                if (block[y][x] != block[otherI][x])
                {
                    error++;
                }
            }
        }
        return error;
    }

    private static int ReflectionErrorVertical(string[] block, int col)
    {
        var width = block[0].Length;
        var error = 0;
        for (var x = 0; x < width; x++)
        {
            var otherI = Reflect(x, col) + 1;
            if (otherI < x || otherI < 0 || otherI >= width) continue;
            for (var y = 0; y < block.Length; y++)
            {
                if (block[y][x] != block[y][otherI])
                {
                    error++;
                }
            }
        }
        return error;
    }
}
