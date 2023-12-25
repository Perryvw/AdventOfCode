namespace AoC2023;

public partial class Day25(ITestOutputHelper output) : AoCSolution<long, int, Dictionary<string, HashSet<string>>>(output)
{
    protected override int Iterations => 8;

    protected override Dictionary<string, HashSet<string>> LoadData()
    {
        var dict = new Dictionary<string, HashSet<string>>();
        var lines = LoadLinesFromFile("day25.txt");
        foreach (var l in lines)
        {
            var spl = l.Split(':');
            dict[spl[0]] = spl[1].Split(' ', StringSplitOptions.RemoveEmptyEntries).ToHashSet();
        }
        var nodes = dict.Values.SelectMany(e => e).ToList();
        foreach (var node in nodes)
        {
            if (!dict.ContainsKey(node))
            {
                dict[node] = new HashSet<string>();
            }
        }
        foreach (var edge in dict)
        {
            foreach (var to in edge.Value)
            {
                dict[to].Add(edge.Key);
            }
        }
        return dict;
    }

    protected override (long p1, int p2) Solve()
    {
        var p1 = 0L;

        // Run Krager's algorithm contraction until we find a suitable answer
        while (p1 == 0)
        {
            var edges = Data.SelectMany(kvp => kvp.Value.Select(v => (kvp.Key, v))).ToArray();
            Random.Shared.Shuffle(edges); // Randomize order of picking edges

            List<HashSet<string>> groups = [];

            foreach (var (from, to) in edges)
            {
                // Stop when we found a suitable subdivision
                // Why 10? idk it seems to work
                if (groups.Count == 2 && groups[0].Count + groups[1].Count == Data.Count && groups[0].Count > 10 && groups[1].Count > 10)
                {
                    p1 = (long)groups[0].Count * (long)groups[1].Count;
                    break;
                }

                // Check if either end of the edge is already in a group
                var existingGroupFrom = groups.FirstOrDefault(g => g.Contains(from));
                var existingGroupTo = groups.FirstOrDefault(g => g.Contains(to));

                if (existingGroupFrom != null && existingGroupTo != null)
                {
                    // Both nodes are already in the same group, continue
                    if (existingGroupFrom == existingGroupTo) continue;

                    // Both are in a different group, merge the groups
                    foreach (var n in existingGroupFrom)
                    {
                        existingGroupTo.Add(n);
                    }
                    groups.Remove(existingGroupFrom);
                }
                // Only one end is in a group, add the other one to the same group
                else if (existingGroupTo != null)
                {
                    existingGroupTo.Add(from);
                }
                else if (existingGroupFrom != null)
                {
                    existingGroupFrom.Add(to);
                }
                // Neither are in a group, add a new group to the list
                else
                {
                    groups.Add([from, to]);
                }
            }
        }

        return (p1, 0);
    }
}
