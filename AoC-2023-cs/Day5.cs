namespace AoC2023;

public partial class Day5(ITestOutputHelper output) : AoCSolution<long, long, Day5.Input>(output)
{
    public record struct Input
    {
        public long[] Seeds;
        public Mapping[] Maps;
    }

    public record struct Mapping
    {
        public string From;
        public string To;
        public RangeMapping[] Ranges;
    }

    public record struct RangeMapping
    {
        public Range SourceRange;
        public Range DestinationRange;
    }

    public record struct Range
    {
        public long Start;
        public long Length;

        public readonly long End => Start + Length - 1;

        public override string ToString() => $"[{Start}-{End}]";
    }

    protected override Input LoadData()
    {
        var lines = LoadStringFromFile("day5.txt");
        var blocks = lines.Split($"{Environment.NewLine}{Environment.NewLine}");
        var seeds = blocks[0].Split(":")[1].Trim().Split(" ").Select(long.Parse).ToArray();

        var maps = blocks.Skip(1).Select(block =>
            {
                var lines = block.Split(Environment.NewLine);
                var fromto = lines[0].Split(" ")[0].Split("-to-");
                var ranges = lines.Skip(1).Select(l =>
                {
                    var nums = l.Split(" ").Select(long.Parse).ToList();
                    return new RangeMapping
                    {
                        DestinationRange = new Range { Start = nums[0], Length = nums[2] },
                        SourceRange = new Range { Start = nums[1], Length = nums[2] },
                    };
                }).ToArray();
                return new Mapping
                {
                    From = fromto[0],
                    To = fromto[1],
                    Ranges = ranges
                };
            })
            .ToArray();

        return new Input
        {
            Seeds = seeds,
            Maps = maps
        };
    }

    protected override (long p1, long p2) Solve()
    {
        // P1
        var p1Ranges = Data.Seeds.Select(s => new Range { Start = s, Length = 1 }).ToList();
        foreach (var mapping in Data.Maps)
        {
            p1Ranges = Map(p1Ranges, mapping.Ranges);
        }

        var p1 = p1Ranges.MinBy(r => r.Start).Start;

        // P2
        var ranges = new List<Range>();
        for (var i = 0; i < Data.Seeds.Length; i += 2)
        {
            ranges.Add(new Range { Start = Data.Seeds[i], Length = Data.Seeds[i + 1] });
        }

        foreach (var mapping in Data.Maps)
        {
            ranges = Map(ranges, mapping.Ranges);
        }

        var p2 = ranges.MinBy(r => r.Start).Start;

        return (p1, p2);
    }

    private List<Range> Map(List<Range> unmapped, RangeMapping[] mappings)
    {
        var next = new List<Range>();
        var result = new List<Range>();

        foreach (var mapping in mappings)
        {
            foreach (var r in unmapped)
            {
                var (m, u) = Map(r, mapping);
                if (m != null) result.Add(m.Value);
                next.AddRange(u);
            }
            unmapped = next;
            next = new List<Range>();
        }

        result.AddRange(unmapped);
        return result;
    }

    private (Range? Mapped, List<Range> Unmapped) Map(Range range, RangeMapping mapping)
    {
        var headingNum = mapping.SourceRange.Start - range.Start;
        var trailingNum = range.End - mapping.SourceRange.End;

        if (mapping.SourceRange.Start <= range.Start && mapping.SourceRange.End >= range.End)
        {
            return (new Range { Start = range.Start + (mapping.DestinationRange.Start - mapping.SourceRange.Start), Length = range.Length }, new List<Range>());
        }
        if (mapping.SourceRange.Start >= range.Start && mapping.SourceRange.End <= range.End)
        {
            // ====|****|=====
            var mappedRange = mapping.DestinationRange; // source range is equal to mapping, so destination range is also equal
            var unmapped = new List<Range>();
            if (headingNum > 0) unmapped.Add(new() { Start = range.Start, Length = headingNum });
            if (trailingNum > 0) unmapped.Add(new() { Start = mapping.SourceRange.End + 1, Length = trailingNum });
            return (mappedRange, unmapped);
        }
        else if (mapping.SourceRange.Start >= range.Start && mapping.SourceRange.Start <= range.End)
        {
            // ======|*****
            var length = range.End - mapping.SourceRange.Start + 1;
            var mappedRange = new Range { Start = mapping.DestinationRange.Start, Length = length };

            return (mappedRange, new List<Range> { new Range { Start = range.Start, Length = range.Length - length } });
        }
        else if (mapping.SourceRange.End >= range.Start && mapping.SourceRange.End <= range.End)
        {
            // *****|======
            var length = mapping.SourceRange.End - range.Start + 1;
            var mappedRange = new Range { Start = mapping.DestinationRange.Start + (range.Start - mapping.SourceRange.Start), Length = length };

            return (mappedRange, new List<Range> { new Range { Start = mapping.SourceRange.End + 1, Length = range.Length - length } });
        }
        else
        {
            return (null, new List<Range> { range });
        }
    }

    [Fact]
    public void TestMapContained()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 3 }, SourceRange = { Start = 3, Length = 3 } });
        Assert.Equal(new Range { Start = 10, Length = 3 }, mapped);
        Assert.Equal(new Range { Start = 1, Length = 2 }, unmapped[0]);
        Assert.Equal(new Range { Start = 6, Length = 5 }, unmapped[1]);
        LogOutput($"{unmapped[0]}{mapped}{unmapped[1]}");
    }

    [Fact]
    public void TestMapFront1()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 4 }, SourceRange = { Start = 1, Length = 4 } });
        LogOutput($"{mapped}{unmapped[0]}");
        Assert.Equal(new Range { Start = 10, Length = 4 }, mapped);
        Assert.Equal(new Range { Start = 5, Length = 6 }, unmapped[0]);
    }

    [Fact]
    public void TestMapFront2()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 6 }, SourceRange = { Start = -2, Length = 6 } });
        LogOutput($"{mapped}{unmapped[0]}");
        Assert.Equal(new Range { Start = 13, Length = 3 }, mapped);
        Assert.Equal(new Range { Start = 4, Length = 7 }, unmapped[0]);
    }

    [Fact]
    public void TestMapBack1()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 4 }, SourceRange = { Start = 7, Length = 4 } });
        LogOutput($"{unmapped[0]}{mapped}");
        Assert.Equal(new Range { Start = 10, Length = 4 }, mapped);
        Assert.Equal(new Range { Start = 1, Length = 6 }, unmapped[0]);
    }

    [Fact]
    public void TestMapBack2()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 10 }, SourceRange = { Start = 7, Length = 10 } });
        LogOutput($"{unmapped[0]}{mapped}");
        Assert.Equal(new Range { Start = 10, Length = 4 }, mapped);
        Assert.Equal(new Range { Start = 1, Length = 6 }, unmapped[0]);
    }

    [Fact]
    public void TestMapOutside1()
    {
        var rangeIn = new Range { Start = 1, Length = 10 };
        var (mapped, unmapped) = Map(rangeIn, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 10 }, SourceRange = { Start = 13, Length = 10 } });
        Assert.Null(mapped);
        Assert.Equal(rangeIn, unmapped[0]);
    }

    [Fact]
    public void TestMapOutside2()
    {
        var rangeIn = new Range { Start = 1, Length = 10 };
        var (mapped, unmapped) = Map(rangeIn, new RangeMapping { DestinationRange = new Range { Start = 10, Length = 10 }, SourceRange = { Start = -13, Length = 10 } });
        Assert.Null(mapped);
        Assert.Equal(rangeIn, unmapped[0]);
    }

    [Fact]
    public void TestMapOuter()
    {
        var (mapped, unmapped) = Map(new Range { Start = 1, Length = 10 }, new RangeMapping { DestinationRange = new Range { Start = 20, Length = 50 }, SourceRange = { Start = -10, Length = 40 } });
        Assert.Equal(new Range { Start = 31, Length = 10 }, mapped);
        Assert.Empty(unmapped);
    }
}
