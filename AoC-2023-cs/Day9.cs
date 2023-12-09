namespace AoC2023;

public partial class Day9(ITestOutputHelper output) : AoCSolution<long, long, long[][]>(output)
{
    protected override long[][] LoadData()
        => LoadLinesFromFile("day9.txt")
            .Select(l => l.Split(" ").Select(long.Parse).ToArray())
            .ToArray();

    protected override (long p1, long p2) Solve()
    {
        var p1 = Data
            .Select(NextVal)
            .Sum();

        var p2 = Data
            .Select(s => NextVal(s.Reverse()))
            .Sum();

        return (p1, p2);
    }

    protected IEnumerable<long> NextSequence(IEnumerable<long> sequence)
    {
        var previous = sequence.First();
        foreach (var item in sequence.Skip(1))
        {
            yield return item - previous;
            previous = item;
        }
    }

    protected long NextVal(IEnumerable<long> sequence)
        => sequence.All(v => v == 0)
            ? 0
            : sequence.Last() + NextVal(NextSequence(sequence).ToList());
}
