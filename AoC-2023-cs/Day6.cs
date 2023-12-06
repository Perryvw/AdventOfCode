namespace AoC2023;

public partial class Day6(ITestOutputHelper output) : AoCSolution<int, int, List<Day6.Race>>(output)
{
    public struct Race
    {
        public int Time;
        public int RecordDistance;
    }

    protected override List<Race> LoadData()
    {
        var lines = LoadLinesFromFile("day6.txt");
        var times = lines[0].Split(":")[1].Split(" ", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();
        var distances = lines[1].Split(":")[1].Split(" ", StringSplitOptions.RemoveEmptyEntries).Select(int.Parse).ToArray();

        return Enumerable.Range(0, times.Length).Select(i => new Race { Time = times[i], RecordDistance = distances[i] }).ToList();
    }

    protected override (int p1, int p2) Solve()
    {
        var p1 = Data.Select(race =>
            {
                var (min, max) = WinningPressDurations(race.Time, race.RecordDistance);
                return max - min + 1;
            })
            .Product();

        var p2Time = Data.Aggregate(0l, (current, next) =>
        {
            var nextSize = Math.Floor(Math.Log10(next.Time)) + 1;
            return (long)Math.Pow(10, nextSize) * current + next.Time;
        });
        var p2Distance = Data.Aggregate(0l, (current, next) =>
        {
            var nextSize = Math.Floor(Math.Log10(next.RecordDistance)) + 1;
            return (long)Math.Pow(10, nextSize) * current + next.RecordDistance;
        });

        var (p2Min, p2Max) = WinningPressDurations(p2Time, p2Distance);
        var p2 = p2Max - p2Min + 1;

        return (p1, p2);
    }

    (int min, int max) WinningPressDurations(long tRace, long raceDistance)
    {
        // Distance travelled d = tButton * (tRace - tButton)
        // We care about the cases where d > raceDistance + 1, so we can solve where the parabola for d - (raceDistance + 1) intersects 0
        // and then subtract the two intersection points with the y axis:
        // tButton * (tRace - tButton) - (raceDistance + 1) = 0
        // -tButton^2 + tRace * tButton - (raceDistance + 1) = 0
        //
        // Use the quadratic formula:
        // tButton_1 = ( -tRace - sqrt( tRace^2 - 4 * -1 * -(raceDistance + 1 ) ) ) / -2
        // tButton_2 = ( -tRace + sqrt( tRace^2 - 4 * -1 * -(raceDistance + 1 ) ) ) / -2
        var intersection1 = (-tRace - Math.Sqrt(tRace*tRace - 4 * -1 * -(raceDistance + 1))) / -2;
        var intersection2 = (-tRace + Math.Sqrt(tRace*tRace - 4 * -1 * -(raceDistance + 1))) / -2;
        return ((int)Math.Ceiling(intersection2), (int)Math.Floor(intersection1));
    }
}
