using System.Diagnostics;

namespace AoC2023;

public abstract class AoCSolution<TResultP1, TResultP2, TData>(ITestOutputHelper output)
{
    private readonly ITestOutputHelper _output = output;

    protected abstract (TResultP1 p1, TResultP2 p2) Solve(); // To be implemented by solver

    protected virtual int Iterations => 1000;

    protected TData Data { get; private set; } = default!;

    [Fact]
    public void Run()
    {
        Data = LoadData();

        var (p1, p2) = Solve();

        LogOutput("Part 1:");
        LogOutput($"   {p1}");
        LogOutput("Part 2:");
        LogOutput($"   {p2}");

#if !DEBUG
        var stopwatch = new Stopwatch();

        var times = new List<double>();

        for (var i = 0; i < Iterations; i++)
        {
            stopwatch.Reset();
            stopwatch.Start();
            Solve();
            stopwatch.Stop();
            times.Add(stopwatch.Elapsed.TotalMilliseconds);
        }

        var mean = times.Select(t => t / Iterations).Sum();
        var min = times.Min();
        var max = times.Max();

        LogOutput("");
        LogOutput($"Benchmark ({Iterations} iterations)");
        LogOutput($"|{"Mean (ms)",11} |{"Min (ms)",11} |{"Max (ms)",11} |");
        LogOutput($"|------------|------------|------------|");
        LogOutput($"|{mean,11:F3} |{min,11:F3} |{max,11:F3} |");
#endif
    }

    protected virtual TData LoadData()
    {
        return default!;
    }

    protected string LoadStringFromFile(string filePath)
    {
        var executableDir = AppDomain.CurrentDomain.BaseDirectory;
        var projectRoot = Path.GetDirectoryName(Path.GetDirectoryName(Path.GetDirectoryName(Path.GetDirectoryName(executableDir))));
        return File.ReadAllText(Path.Join(projectRoot, "Data", filePath));
    }

    protected string[] LoadLinesFromFile(string filePath)
    {
        return LoadStringFromFile(filePath).Split(Environment.NewLine);
    }

    protected void LogOutput(object message)
    {
        _output.WriteLine(message.ToString());
    }
}
