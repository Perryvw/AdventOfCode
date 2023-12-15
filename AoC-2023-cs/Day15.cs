namespace AoC2023;

using LensBox = List<(string Label, int FocalValue)>;

public partial class Day15(ITestOutputHelper output) : AoCSolution<int, long, string[]>(output)
{
    protected override string[] LoadData() => LoadStringFromFile("day15.txt").Split(",");

    protected override (int p1, long p2) Solve()
    {
        var p1 = Data.Select(HASH).Sum();

        var boxes = Enumerable.Range(0, 256).Select(_ => new LensBox()).ToArray();

        foreach (var instruction in Data)
        {
            if (instruction.EndsWith('-'))
            {
                var label = instruction.Substring(0, instruction.Length - 1);
                Remove(boxes, label);
            }
            else
            {
                var spl = instruction.Split('=');
                var label = spl[0];
                var lens = int.Parse(spl[1]);
                Add(boxes, label, lens);
            }
        }

        var p2 = boxes
            .Select((box, boxNum) => box.Select((lens, lensSlot) => (long)(boxNum + 1) * (lensSlot + 1) * lens.FocalValue).Sum())
            .Sum();

        return (p1, p2);
    }

    private void Add(LensBox[] boxes, string label, int value)
    {
        var hash = HASH(label);
        var existingLens = boxes[hash].FindIndex(t => t.Label == label);
        if (existingLens >= 0)
        {
            boxes[hash][existingLens] = (label, value);
        }
        else
        {
            boxes[hash].Add((label, value));
        }
    }

    private void Remove(LensBox[] boxes, string label)
    {
        var hash = HASH(label);
        boxes[hash].RemoveAll(t => t.Label == label);
    }

    private int HASH(string str)
    {
        var hash = 0;

        foreach (var c in str)
        {
            hash += c;
            hash *= 17;
            hash %= 256;
        }

        return hash;
    }

    [Fact]
    public void TestHASH()
    {
        Assert.Equal(52, HASH("HASH"));
    }
}
