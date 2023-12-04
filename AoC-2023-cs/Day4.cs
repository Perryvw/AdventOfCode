namespace AoC2023;

using Card = (int N, int[] WinningNumbers, int[] YourNumbers);
using TData = List<(int N, int[] WinningNumbers, int[] YourNumbers)>;

public partial class Day4(ITestOutputHelper output) : AoCSolution<int, int, TData>(output)
{
    protected override TData LoadData()
        => LoadLinesFromFile("day4.txt")
            .Select((l, i) =>
            {
                var parts = l.Split(":")[1].Split("|");
                return (
                    i + 1,
                    parts[0].Trim().Split(" ", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray(),
                    parts[1].Trim().Split(" ", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray()
                );
            })
            .ToList();

    protected override (int p1, int p2) Solve()
    {
        var p1 = Data
            .Select(Score)
            .Sum();

        var cache = new Dictionary<int, int>();
        var p2 = Data
            .Select(c => NumCardsWon(c, Data, cache))
            .Sum();

        return (p1, p2);
    }

    private int Score(Card card)
    {
        var overlappingNums = card.YourNumbers.Where(n => card.WinningNumbers.Contains(n)).Count();
        return overlappingNums == 0 ? 0 : 1 << (overlappingNums - 1);
    }

    private int NumCardsWon(Card card, List<Card> cards, Dictionary<int, int> cache)
    {
        var overlappingNums = card.YourNumbers.Where(n => card.WinningNumbers.Contains(n)).Count();
        var result = 1;
        foreach (var nextCard in Enumerable.Range(card.N, overlappingNums))
        {
            if (cache.TryGetValue(nextCard, out var cachedValue))
            {
                result += cachedValue;
            }
            else
            {
                var val = NumCardsWon(cards[nextCard], cards, cache);
                result += val;
                cache.Add(nextCard, val);
            }
        }
        return result;
    }
}
