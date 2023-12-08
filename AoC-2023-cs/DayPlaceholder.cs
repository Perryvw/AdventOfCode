namespace AoC2023;

public partial class DayPlaceholder(ITestOutputHelper output) : AoCSolution<int, int, string[]>(output)
{
    protected override string[] LoadData()
    {
        var lines = LoadLinesFromFile("day7.txt");
        return lines;
    }

    protected override (int p1, int p2) Solve()
    {

        return (0, 0);
    }
}
