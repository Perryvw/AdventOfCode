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
        stopwatch.Start();

        for (var i = 0; i < Iterations; i++)
        {
            Solve();
        }

        stopwatch.Stop();

        var avgTime = stopwatch.Elapsed / Iterations;

        LogOutput("");
        LogOutput($"Average time: {avgTime.TotalMilliseconds}ms ({Iterations} iterations)");
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
