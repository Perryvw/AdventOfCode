namespace AoC2023;

using TData = string[];
using TResultP1 = int;
using TResultP2 = int;

record struct GridNumber(int Value, int StartX, int EndX)
{
}

record struct GridSymbol(char Symbol, int X)
{
}

public partial class Day3(ITestOutputHelper output) : AoCSolution<TResultP1, TResultP2, TData>(output)
{
    protected override TData LoadData() => LoadLinesFromFile("day3.txt");

    protected override (TResultP1 p1, TResultP2 p2) Solve()
    {
        List<List<GridNumber>> Nrs = new();
        List<List<GridSymbol>> Symbols = new();

        for (var y = 0; y < Data.Length; y++)
        {
            var nrRow = new List<GridNumber>();
            var symbolRow = new List<GridSymbol>();

            int? nr = null;
            int nrStart = 0;
            for (var x = 0; x < Data[y].Length; x++)
            {
                if (char.IsAsciiDigit(Data[y][x]))
                {
                    if (nr == null)
                    {
                        nr = Data[y][x] - '0';
                        nrStart = x;
                    }
                    else
                    {
                        nr = (10 * nr) + (Data[y][x] - '0');
                    }
                }
                else
                {
                    if (nr != null)
                    {
                        nrRow.Add(new GridNumber(nr.Value, nrStart, x - 1));
                        nr = null;
                    }

                    if (Data[y][x] != '.')
                    {
                        symbolRow.Add(new GridSymbol(Data[y][x], x));
                    }
                }
            }

            if (nr != null)
            {
                nrRow.Add(new GridNumber(nr.Value, nrStart, Data.Length - 1));
            }
            Nrs.Add(nrRow);
            Symbols.Add(symbolRow);
        }


        var p1 = 0;
        var p2 = 0;

        for (var y = 0; y < Nrs.Count; y++)
        {
            // P1
            foreach (var nr in Nrs[y])
            {
                // Only check rows surrounding the number
                var touchingSymbol = (y > 0 && Symbols[y - 1].Any(s => (s.X >= nr.StartX - 1) && (s.X <= nr.EndX + 1)))
                    || Symbols[y].Any(s => (s.X >= nr.StartX - 1) && (s.X <= nr.EndX + 1))
                    || (y < Nrs.Count - 1 && Symbols[y + 1].Any(s => (s.X >= nr.StartX - 1) && (s.X <= nr.EndX + 1)));

                if (touchingSymbol)
                {
                    p1 += nr.Value;
                }
            }

            // P2
            foreach (var gear in Symbols[y].Where(s => s.Symbol == '*'))
            {
                var touchingNrs = Nrs[y].Where(nr => (gear.X >= nr.StartX - 1) && (gear.X <= nr.EndX + 1));
                if (y > 0) touchingNrs = touchingNrs.Concat(Nrs[y - 1].Where(nr => (gear.X >= nr.StartX - 1) && (gear.X <= nr.EndX + 1)));
                if (y < Nrs.Count - 1) touchingNrs = touchingNrs.Concat(Nrs[y + 1].Where(nr => (gear.X >= nr.StartX - 1) && (gear.X <= nr.EndX + 1)));

                int count = 0;
                int product = 1;
                foreach (var n in touchingNrs)
                {
                    count++;
                    product *= n.Value;

                    if (count > 2) break;
                }

                if (count == 2) p2 += product;
            }
        }

        return (p1, p2);
    }
}
