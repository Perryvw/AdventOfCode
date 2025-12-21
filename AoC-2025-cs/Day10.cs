using System.Text;
using AoC_2025_cs.Common;

namespace AoC_2025_cs;

public class Day10
{
    record MachineManual
    {
        public string indicatorLights;
        public List<List<int>> buttons;
        public List<long> joltageRequirements;
    }

    [Fact]
    public async Task P1P2()
    {
        long p1 = 0;
        long p2 = 0;

        var lines = await File.ReadAllLinesAsync("../../../data/day10.txt", TestContext.Current.CancellationToken);

        var machineManuals = lines.Select(line =>
        {
            var endOfLightDiagram = line.IndexOf(']');
            var startOfJoltageRequirements = line.IndexOf('{');

            var buttons = line[(endOfLightDiagram + 2)..(startOfJoltageRequirements - 1)];

            return new MachineManual
            {
                indicatorLights = line[1..endOfLightDiagram],
                buttons = [.. buttons.Split(' ').Select(l => l[1..(l.Length - 1)].Split(',').Select(int.Parse).ToList())],
                joltageRequirements = [.. line[(startOfJoltageRequirements + 1)..(line.Length - 1)].Split(',').Select(long.Parse)]
            };
        }).ToList();

        // P1
        p1 = machineManuals.Select(p1Search).Sum();

        // p2 MiniZinc solution:

        // var sb = new StringBuilder();
        // var vars = new List<string>();

        // for (var machineId = 0; machineId < machineManuals.Count; machineId++)
        // {
        //     for (var buttonId = 0; buttonId < machineManuals[machineId].buttons.Count; buttonId++)
        //     {
        //         var buttonName = $"m{machineId}b{buttonId}";
        //         sb.AppendLine($"var 0..1000: {buttonName};");
        //         vars.Add(buttonName);
        //     }

        //     for (var joltageId = 0; joltageId < machineManuals[machineId].joltageRequirements.Count; joltageId++)
        //     {
        //         List<string> buttons = [];
        //         for (var buttonId = 0; buttonId < machineManuals[machineId].buttons.Count; buttonId++)
        //         {
        //             if (machineManuals[machineId].buttons[buttonId].Contains(joltageId))
        //             {
        //                 buttons.Add($"m{machineId}b{buttonId}");
        //             }
        //         }
        //         sb.AppendLine($"constraint ({string.Join('+', buttons)}) == {machineManuals[machineId].joltageRequirements[joltageId]};");
        //     }
        // }
        // sb.AppendLine($"solve minimize {string.Join('+', vars)};");
        // File.WriteAllText("d10p2.mzn", sb.ToString());


        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private long p1Search(MachineManual machine)
    {
        // do BFS starting from all ....
        HashSet<string> states = [new string('.', machine.indicatorLights.Length)];
        HashSet<string> next = [];
        var presses = 0;
        while (true)
        {
            presses += 1;
            foreach (var state in states)
            {
                foreach (var button in machine.buttons)
                {
                    var result = Toggle(state, button);
                    if (result == machine.indicatorLights) return presses;
                    next.Add(result);
                }
            }
            states = next;
            next = [];
        }
    }

    private static string Toggle(string inp, List<int> ns)
    {
        char[] chars = inp.ToCharArray();
        foreach (var n in ns)
        {
            chars[n] = inp[n] == '#' ? '.' : '#';
        }
        return new string(chars);
    }
}
