namespace AoC2023;

using Turn = (OpponentAction Opponent, YourAction You);

public enum OpponentAction
{
    Rock = 'A',
    Paper = 'B',
    Scissors = 'C'
}

public enum YourAction
{
    X = 'X',
    Y = 'Y',
    Z = 'Z'
}

public class Day2(ITestOutputHelper output) : AoCSolution<int, int, List<Turn>>(output)
{
    protected override List<Turn> LoadData()
        => LoadLinesFromFile("day2.txt")
        .Select(l => ((OpponentAction)l[0], (YourAction)l[2]))
        .ToList();

    protected override (int p1, int p2) Solve()
    {
        var p1 = Data
            .Select(static t => ActionScore(t.You) + ResultScore(t.Opponent, t.You))
            .Sum();

        var p2 = Data
            .Select(static t => ActionScore(ActionForResult(t.Opponent, t.You)) + ResultScore(t.You))
            .Sum();

        return (p1, p2);
    }

    private static int ActionScore(YourAction act) =>
        act switch
        {
            YourAction.X => 1,
            YourAction.Y => 2,
            YourAction.Z => 3,
        };

    private static int ResultScore(OpponentAction opp, YourAction you) =>
        (opp, you) switch
        {
            (OpponentAction.Rock, YourAction.X) => 3,
            (OpponentAction.Rock, YourAction.Y) => 6,
            (OpponentAction.Rock, YourAction.Z) => 0,
            (OpponentAction.Paper, YourAction.X) => 0,
            (OpponentAction.Paper, YourAction.Y) => 3,
            (OpponentAction.Paper, YourAction.Z) => 6,
            (OpponentAction.Scissors, YourAction.X) => 6,
            (OpponentAction.Scissors, YourAction.Y) => 0,
            (OpponentAction.Scissors, YourAction.Z) => 3,
        };

    private static int ResultScore(YourAction result) =>
        result switch
        {
            YourAction.X => 0,
            YourAction.Y => 3,
            YourAction.Z => 6,
        };

    private static YourAction ActionForResult(OpponentAction opp, YourAction desiredResult) =>
        (opp, desiredResult) switch
        {
            (OpponentAction.Rock, YourAction.X) => YourAction.Z,
            (OpponentAction.Rock, YourAction.Y) => YourAction.X,
            (OpponentAction.Rock, YourAction.Z) => YourAction.Y,
            (OpponentAction.Paper, YourAction.X) => YourAction.X,
            (OpponentAction.Paper, YourAction.Y) => YourAction.Y,
            (OpponentAction.Paper, YourAction.Z) => YourAction.Z,
            (OpponentAction.Scissors, YourAction.X) => YourAction.Y,
            (OpponentAction.Scissors, YourAction.Y) => YourAction.Z,
            (OpponentAction.Scissors, YourAction.Z) => YourAction.X,
        };
}
