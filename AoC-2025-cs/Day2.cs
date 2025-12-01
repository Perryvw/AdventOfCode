namespace AoC_2025_cs;

public class Day2
{
    [Fact]
    public async Task P1P2()
    {
        var input = await File.ReadAllLinesAsync("../../../data/day1.txt", TestContext.Current.CancellationToken);

        var p1 = 0;  
        var p2 = 0;    

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
