namespace AoC2023;

public partial class Day8(ITestOutputHelper output) : AoCSolution<long, long, Day8.Input>(output)
{
    public struct Input
    {
        public string RLInstructions;
        public Dictionary<string, (string Left, string Right)> Map;
    }
    protected override Input LoadData()
    {
        var lines = LoadLinesFromFile("day8.txt");
        return new Input
        {
            RLInstructions = lines[0],
            Map = lines.Skip(2)
            .Select(l => (l.Substring(0, 3), l.Substring(7, 3), l.Substring(12, 3)))
            .ToDictionary(t => t.Item1, t => (t.Item2, t.Item3))
        };
    }

    protected override (long p1, long p2) Solve()
    {
        var steps = 0L;
        var current = "AAA";
        while (current != "ZZZ")
        {
            if (Data.RLInstructions[(int)(steps % Data.RLInstructions.Length)] == 'L')
            {
                current = Data.Map[current].Left;
            }
            else
            {
                current = Data.Map[current].Right;
            }
            steps++;
        }

        var p1 = steps;

        // P2
        steps = 0;
        var nodes = Data.Map.Keys.Where(k => k.EndsWith('A')).ToArray();
        var distanceToZ = new long[nodes.Length];

        while (distanceToZ.Any(c => c == 0))
        {
            for (var i = 0; i < nodes.Length; i++)
            {
                if (distanceToZ[i] > 0) continue;

                if (Data.RLInstructions[(int)(steps % Data.RLInstructions.Length)] == 'L')
                {
                    nodes[i] = Data.Map[nodes[i]].Left;
                }
                else
                {
                    nodes[i] = Data.Map[nodes[i]].Right;
                }

                if (nodes[i].EndsWith('Z'))
                {
                    distanceToZ[i] = steps + 1;
                }
            }
            steps++;
        }

        var p2 = distanceToZ.LeastCommonMultiple();

        return (p1, p2);
    }
}
