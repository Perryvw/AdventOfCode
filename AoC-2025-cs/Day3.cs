namespace AoC_2025_cs;

public class Day3
{
    [Fact]
    public async Task P1P2()
    {
        var banks = await File.ReadAllLinesAsync("../../../data/day3.txt", TestContext.Current.CancellationToken);

        long p1 = 0;
        long p2 = 0;

        foreach (var bank in banks)
        {
            p1 += FindHighestValue(bank, 2);
            p2 += FindHighestValue(bank, 12);
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private static long FindHighestValue(string bank, int numDigits)
    {
        long result = 0;
        var index = 0;

        for (var digit = 1; digit <= numDigits; digit++)
        {
            char max = '0';
            for (var i = index; i < bank.Length - (numDigits - digit); i++)
            {
                if (bank[i] > max)
                {
                    max = bank[i];
                    index = i + 1;
                }
            }
            result += (long)Math.Pow(10, numDigits - digit) * (max - '0');
        }

        return result;
    }
}
