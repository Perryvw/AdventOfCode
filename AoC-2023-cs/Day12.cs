using System.Collections.Concurrent;

namespace AoC2023;

public partial class Day12(ITestOutputHelper output) : AoCSolution<long, long, List<(string Springs, int[] Groups)>>(output)
{
    protected override List<(string Springs, int[] Groups)> LoadData()
        => LoadLinesFromFile("day12.txt")
            .Select(l =>
            {
                var parts = l.Split(" ");
                return (parts[0], parts[1].Split(",").Select(int.Parse).ToArray());
            })
            .ToList();

    protected override (long p1, long p2) Solve()
    {
        var p1 = Data
            .Select(l => NumPossibilities(l.Springs, l.Groups, 0))
            .Sum();
        var p2 = Data.AsParallel().Select(l =>
            {
                var inp2 = l.Springs.Repeat(5, "?").ToArray();
                var groups2 = l.Groups.Repeat(5).ToArray();
                return NumPossibilities(inp2, groups2, 0);
            })
            .Sum();

        return (p1, p2);
    }

    private ConcurrentDictionary<(string, string, int), long> Cache = new ConcurrentDictionary<(string, string, int), long>();

    private long NumPossibilities(ReadOnlySpan<char> str, ReadOnlySpan<int> groups, int depthInCurrentGroup)
    {
        var strKey = str.ToString();
        var groupKey = "";
        for (var i = 0; i < groups.Length; i++)
        {
            groupKey += groups[i] + 'a';
        }

        if (Cache.TryGetValue((strKey, groupKey, depthInCurrentGroup), out var v))
        {
            return v;
        }
        else
        {
            var val = _NumPossibilities(str, groups, depthInCurrentGroup);
            Cache.TryAdd((strKey, groupKey, depthInCurrentGroup), val);
            return val;
        }
    }

    private long _NumPossibilities(ReadOnlySpan<char> str, ReadOnlySpan<int> groups, int depthInCurrentGroup)
    {
        if (str.Length == 0)
        {
            if (groups.Length == 0) return 1;
            else if (groups.Length == 1 && depthInCurrentGroup == groups[0]) return 1;
            else return 0;
        }

        // Just for optimization
        if (str.Length < groups.Length * 2 - 2) return 0;

        if (str[0] == '.')
        {
            if (depthInCurrentGroup > 0)
            {
                if (depthInCurrentGroup == groups[0]) return NumPossibilities(str.Slice(1), groups.Slice(1), 0);
                else return 0; // Not valid, prune
            }
            else
            {
                return NumPossibilities(str.Slice(1), groups, 0);
            }
        }
        else if (str[0] == '#')
        {
            if (groups.Length == 0) return 0;
            if (depthInCurrentGroup == groups[0]) return 0; // Invalid, prune

            return NumPossibilities(str.Slice(1), groups, depthInCurrentGroup + 1);
        }
        else if (str[0] == '?')
        {
            if (depthInCurrentGroup > 0)
            {
                if (groups.Length > 0 && depthInCurrentGroup < groups[0]) return NumPossibilities(str.Slice(1), groups, depthInCurrentGroup + 1);
                else return NumPossibilities(str.Slice(1), groups.Slice(1), 0);
            }
            else
            {
                var res = NumPossibilities(str.Slice(1), groups, 0);
                if (groups.Length > 0) res += NumPossibilities(str.Slice(1), groups, 1);
                return res;
            }
        }
        else throw new Exception("huh?!");
    }
}
