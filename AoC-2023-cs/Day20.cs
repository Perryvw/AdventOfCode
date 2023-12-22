using AoC2023.Util;

namespace AoC2023;

public partial class Day20(ITestOutputHelper output) : AoCSolution<long, long, Dictionary<string, Day20.IModule>>(output)
{
    protected override int Iterations => 100;

    public enum Pulse
    {
        High,
        Low
    }

    public record struct SentPulse(string From, string To, Pulse Pulse) { }

    public interface IModule
    {
        public string Name { get; }
        public string[] Destinations { get; }
        public Dictionary<string, Pulse> Inputs { get; }
        IEnumerable<SentPulse> HandlePulse(SentPulse pulse);
    }

    class BroadcasterModule(string[] destinations) : IModule
    {
        public string Name => "broadcaster";
        public string[] Destinations { get; } = destinations;
        public Dictionary<string, Pulse> Inputs { get; } = [];

        public IEnumerable<SentPulse> HandlePulse(SentPulse pulse)
        {
            foreach (var d in Destinations)
            {
                yield return new SentPulse(Name, d, pulse.Pulse);
            }
        }
    }

    class FlipFlopModule(string name, string[] destinations) : IModule
    {
        public string Name => name;
        public string[] Destinations { get; } = destinations;
        public Dictionary<string, Pulse> Inputs { get; } = [];

        bool On = false;

        public IEnumerable<SentPulse> HandlePulse(SentPulse pulse)
        {
            if (pulse.Pulse == Pulse.Low)
            {
                On = !On;
                foreach (var d in Destinations)
                {
                    yield return new SentPulse(Name, d, On ? Pulse.High : Pulse.Low);
                }
            }
        }
    }

    class ConjunctionModule(string name, string[] destinations) : IModule
    {
        public string Name => name;
        public string[] Destinations { get; } = destinations;
        public Dictionary<string, Pulse> Inputs { get; } = [];

        public IEnumerable<SentPulse> HandlePulse(SentPulse pulse)
        {
            Inputs[pulse.From] = pulse.Pulse;
            if (Inputs.Values.All(v => v == Pulse.High))
            {
                foreach (var d in Destinations)
                {
                    yield return new SentPulse(Name, d, Pulse.Low);
                }
            }
            else
            {
                foreach (var d in Destinations)
                {
                    yield return new SentPulse(Name, d, Pulse.High);
                }
            }
        }
    }

    protected override Dictionary<string, Day20.IModule> LoadData()
    {
        var modules = LoadLinesFromFile("day20.txt")
              .Select(l =>
              {
                  var spl = l.Split(" -> ");
                  var destinations = spl[1].Split(", ");
                  IModule module = spl[0] switch
                  {
                      _ when spl[0].StartsWith('%') => new FlipFlopModule(spl[0][1..], destinations),
                      _ when spl[0].StartsWith('&') => new ConjunctionModule(spl[0][1..], destinations),
                      _ => new BroadcasterModule(destinations)
                  };
                  return module;
              })
              .ToDictionary(m => m.Name);

        foreach (var m in modules.Values)
        {
            foreach (var d in m.Destinations)
            {
                if (modules.ContainsKey(d))
                {
                    modules[d].Inputs[m.Name] = Pulse.Low;
                }
            }
        }

        return modules;
    }

    protected override (long p1, long p2) Solve()
    {
        Queue<SentPulse> pulses = new();

        var countLow = 0L;
        var countHigh = 0L;

        var rxSender = Data.Values.Where(m => m.Destinations.Contains("rx")).First();
        var p2Vals = new Dictionary<string, long>();

        var p1 = 0L;

        for (var i = 0; p2Vals.Count < rxSender.Inputs.Count; i++)
        {
            pulses.Enqueue(new SentPulse("broadcaster", "broadcaster", Pulse.Low));
            while (pulses.TryDequeue(out var p))
            {
                if (p.Pulse == Pulse.Low) countLow++;
                else countHigh++;

                if (p.Pulse == Pulse.High && rxSender.Inputs.ContainsKey(p.From) && !p2Vals.ContainsKey(p.From))
                {
                    p2Vals.Add(p.From, i + 1);
                }

                if (Data.TryGetValue(p.To, out var targetModule))
                {
                    foreach (var nextPulse in targetModule.HandlePulse(p))
                    {
                        pulses.Enqueue(nextPulse);
                    }
                }
            }

            if (i == 999)
            {
                p1 = countLow * countHigh;
            }
        }

        return (p1, p2Vals.Values.LeastCommonMultiple());
    }
}
