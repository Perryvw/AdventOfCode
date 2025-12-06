using System.Numerics;
using System.Text.RegularExpressions;

namespace AoC_2025_cs;

public class Day6
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var lines = await File.ReadAllLinesAsync("../../../data/day6.txt", TestContext.Current.CancellationToken);
        var operators = lines.Last();
        var columnOffsets = operators.Select((c, i) => (c, i)).Where(t => t.c != ' ').Select(t => t.i).ToList();
        var lineEnd = lines.Select(l => l.Length).Max();

        for (var i = 0; i < columnOffsets.Count; i++)
        {
            var op = operators[columnOffsets[i]];
            var columnWidth = i == columnOffsets.Count - 1 ? (lineEnd - columnOffsets[i] + 1) : (columnOffsets[i + 1] - columnOffsets[i]);

            var nums = NumbersHorizontal(lines, columnOffsets[i], columnWidth);
            p1 += op == '+' ? nums.Sum() : nums.Product();

            var nums2 = NumbersVertical(lines, columnOffsets[i], columnWidth);
            p2 += op == '+' ? nums2.Sum() : nums2.Product();
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private static IEnumerable<long> NumbersHorizontal(string[] lines, int columnOffset, int columnWidth)
    {
        for (var y = 0; y < lines.Length - 1; y++)
        {
            long num = 0;
            for (var x = 0; x < columnWidth - 1; x++)
            {
                var c = lines[y][columnOffset + x];
                if (c == ' ') continue;
                num *= 10;
                num += c - '0';
            }

            yield return num;
        }
    }

    private static IEnumerable<long> NumbersVertical(string[] lines, int columnOffset, int columnWidth)
    {
        for (var x = columnWidth - 2; x >= 0; x--)
        {
            long num = 0;
            for (var y = 0; y < lines.Length - 1; y++)
            {
                var c = lines[y][columnOffset + x];
                if (c == ' ') continue;
                num *= 10;
                num += c - '0';
            }

            yield return num;
        }
    }
}
