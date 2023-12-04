namespace AoC2023;

using System.Text.RegularExpressions;

public partial class Day1(ITestOutputHelper output) : AoCSolution<int, int, string[]>(output)
{
    protected override string[] LoadData() => LoadLinesFromFile("day1.txt");

    protected override (int p1, int p2) Solve()
    {
        var ns1 = Data.Select(static l => 10 * FirstDigit(l) + LastDigit(l));

        var ns2 = Data.Select(static l =>
        {
            var first = RegexForwards().Match(l);
            var last = RegexBackwards().Match(l);

            var firstDigit = Parse(first.Value);
            var lastDigit = Parse(last.Value);
            return 10 * firstDigit + lastDigit;
        });

        return (ns1.Sum(), ns2.Sum());
    }

    private static int FirstDigit(string value) => value.First(char.IsAsciiDigit) - '0';
    private static int LastDigit(string value) => value.Last(char.IsAsciiDigit) - '0';

    private static int Parse(string v) => v switch
    {
        "one" => 1,
        "two" => 2,
        "three" => 3,
        "four" => 4,
        "five" => 5,
        "six" => 6,
        "seven" => 7,
        "eight" => 8,
        "nine" => 9,
        "zero" => 0,
        _ => int.Parse(v)
    };

    [GeneratedRegex("one|two|three|four|five|six|seven|eight|nine|zero|\\d")]
    private static partial Regex RegexForwards();
    [GeneratedRegex("one|two|three|four|five|six|seven|eight|nine|zero|\\d", RegexOptions.RightToLeft)]
    private static partial Regex RegexBackwards();
}
