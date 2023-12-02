namespace AoC2023;

using DiceAmounts = (int Red, int Green, int Blue);

public record Game
{
    public int Id { get; init; }
    public List<DiceAmounts> Turns { get; init; } = null!;
}

public partial class Day2(ITestOutputHelper output) : AoCSolution<int, int, List<Game>>(output)
{
    protected override List<Game> LoadData()
    {
        var lines = LoadLinesFromFile("day2.txt");
        return lines.Select((l, i) =>
        {
            var turns = l.Split(":")[1];
            return new Game
            {
                Id = i + 1,
                Turns = turns.Split(";").Select(t =>
                {
                    var diceAmounts = t.Split(",");
                    DiceAmounts amounts = (0, 0, 0);

                    foreach (var diceAmount in diceAmounts)
                    {
                        var dice = diceAmount.Trim().Split(" ");
                        switch (dice[1])
                        {
                            case "red":
                                amounts.Red = int.Parse(dice[0]); break;
                            case "green":
                                amounts.Green = int.Parse(dice[0]); break;
                            case "blue":
                                amounts.Blue = int.Parse(dice[0]); break;
                        }
                    }
                    return amounts;
                }).ToList()
            };
        }).ToList();
    }

    protected override (int p1, int p2) Solve()
    {
        DiceAmounts limitsP1 = (12, 13, 14);

        var p1 = Data
            .Where(game => game.Turns.All(turn => turn.Red <= limitsP1.Red && turn.Green <= limitsP1.Green && turn.Blue <= limitsP1.Blue))
            .Select(game => game.Id)
            .Sum();

        var p2 = Data
            .Select(game => LeastPossibleDice(game))
            .Select(leastPossibleDice => Power(leastPossibleDice))
            .Sum();

        return (p1, p2);
    }

    protected static DiceAmounts LeastPossibleDice(Game game)
    {
        DiceAmounts amounts = (0, 0, 0);
        foreach (var turn in game.Turns)
        {
            amounts.Red = Math.Max(amounts.Red, turn.Red);
            amounts.Green = Math.Max(amounts.Green, turn.Green);
            amounts.Blue = Math.Max(amounts.Blue, turn.Blue);
        }
        return amounts;
    }

    protected static int Power(DiceAmounts dice) =>
        dice.Red * dice.Green * dice.Blue;
}
