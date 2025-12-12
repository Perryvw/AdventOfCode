using AoC_2025_cs.Common;

namespace AoC_2025_cs;

public class Day11
{
    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var lines = await File.ReadAllLinesAsync("../../../data/day11.txt", TestContext.Current.CancellationToken);

        Dictionary<string, List<string>> adjacencyList = [];

        foreach (var line in lines)
        {
            var spl = line.Split(' ');
            var from = spl[0][..^1];
            adjacencyList[from] = [];

            for (var i = 1; i < spl.Length; i++)
            {
                adjacencyList[from].Add(spl[i]);
            }
        }

        Dictionary<string, List<string>> inverseAdjacencyList = [];
        foreach (var (node, outs) in adjacencyList)
        {
            foreach (var o in outs)
            {
                if (inverseAdjacencyList.TryGetValue(o, out var n))
                {
                    n.Add(node);
                }
                else
                {
                    inverseAdjacencyList[o] = [node];
                }
            }
        }

        Dictionary<string, long> memo = [];

        long PathsToYou(string node)
        {
            if (node == "you") return 1;
            if (memo.TryGetValue(node, out var v)) return v;

            var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToYou).Sum() : 0;
            memo.Add(node, result);
            return result;
        }

        Dictionary<string, long> memo2 = [];

        long PathsToSvrViaDacAndFft(string node)
        {
            if (node == "svr") return 0;
            if (memo2.TryGetValue(node, out var v)) return v;

            if (node == "dac")
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvrViaFft).Sum() : 0;
                memo2.Add(node, result);
                return result;
            }
            else if (node == "fft")
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToNodeViaDac).Sum() : 0;
                memo2.Add(node, result);
                return result;
            }
            else
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvrViaDacAndFft).Sum() : 0;
                memo2.Add(node, result);
                return result;
            }
        }

        Dictionary<string, long> memo3 = [];

        long PathsToNodeViaDac(string node)
        {
            if (node == "svr") return 0;
            if (memo3.TryGetValue(node, out var v)) return v;

            if (node == "dac")
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvr).Sum() : 0;
                memo3.Add(node, result);
                return result;
            }
            else
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToNodeViaDac).Sum() : 0;
                memo3.Add(node, result);
                return result;
            }
        }

        Dictionary<string, long> memo4 = [];

        long PathsToSvrViaFft(string node)
        {
            if (node == "svr") return 0;
            if (memo4.TryGetValue(node, out var v)) return v;

            if (node == "fft")
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvr).Sum() : 0;
                memo4.Add(node, result);
                return result;
            }
            else
            {
                var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvrViaFft).Sum() : 0;
                memo4.Add(node, result);
                return result;
            }
        }

        Dictionary<string, long> memo5 = [];

        long PathsToSvr(string node)
        {
            if (node == "svr") return 1;
            if (memo5.TryGetValue(node, out var v)) return v;

            var result = inverseAdjacencyList.TryGetValue(node, out var inputs) ? inputs.Select(PathsToSvr).Sum() : 0;
            memo5.Add(node, result);
            return result;
        }

        p1 = PathsToYou("out");
        p2 = PathsToSvrViaDacAndFft("out");

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
