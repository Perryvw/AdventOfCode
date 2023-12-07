namespace AoC2023;

public partial class Day7(ITestOutputHelper output) : AoCSolution<int, int, List<(Day7.Hand Hand, int Bet)>>(output)
{
    const int JOKER = 11;

    public struct Hand : IComparable<Hand>
    {
        public enum HandKind
        {
            HighCard,
            OnePair,
            TwoPair,
            ThreeOfAKind,
            FullHouse,
            FourOfAKind,
            FiveOfAKind
        }

        public HandKind Kind;

        public int[] Cards;

        public int CompareTo(Hand other)
        {
            var kindDiff = Kind - other.Kind;
            if (kindDiff != 0) return kindDiff;

            for (var i = 0; i < Cards.Length; i++)
            {
                var cardDiff = Cards[i] - other.Cards[i];
                if (cardDiff != 0) return cardDiff;
            }

            return 0;
        }

        public static bool operator <(Hand x, Hand y) { return x.CompareTo(y) < 0; }
        public static bool operator >(Hand x, Hand y) { return x.CompareTo(y) > 0; }

        public override string ToString()
        {
            var cards = Cards.Select(c => c switch
            {
                10 => 'T',
                11 => 'J',
                1 => 'J',
                12 => 'Q',
                13 => 'K',
                14 => 'A',
                _ => (char)(c + '0')
            });
            return $"{string.Join("", cards)} {Kind}";
        }
    }

    protected override List<(Hand, int)> LoadData()
    {
        var lines = LoadLinesFromFile("day7.txt");
        return lines.Select(l =>
        {
            var parts = l.Split(" ");
            return (ParseHand(parts[0]), int.Parse(parts[1]));
        }).ToList();
    }

    private Hand ParseHand(string str)
    {
        var cards = str.Select(c => c switch
        {
            'A' => 14,
            'K' => 13,
            'Q' => 12,
            'J' => 11,
            'T' => 10,
            _ => c - '0'
        }).ToArray();

        var groups = cards
            .GroupBy(c => c)
            .Select(group => (Card: group.Key, Count: group.Count()))
            .OrderByDescending(t => t.Count)
            .ToList();

        var kind = Hand.HandKind.HighCard;
        if (groups[0].Count == 5) kind = Hand.HandKind.FiveOfAKind;
        else if (groups[0].Count == 4) kind = Hand.HandKind.FourOfAKind;
        else if (groups[0].Count == 3 && groups[1].Count == 2) kind = Hand.HandKind.FullHouse;
        else if (groups[0].Count == 3) kind = Hand.HandKind.ThreeOfAKind;
        else if (groups[0].Count == 2 && groups[1].Count == 2) kind = Hand.HandKind.TwoPair;
        else if (groups[0].Count == 2) kind = Hand.HandKind.OnePair;

        return new Hand
        {
            Kind = kind,
            Cards = cards
        };
    }

    protected override (int p1, int p2) Solve()
    {
        var p1 = Data
            .OrderBy(handBet => handBet.Hand)
            .Select((handBet, rank) => (rank + 1) * handBet.Bet)
            .Sum();

        var p2 = Data
            .Select(t => (Hand: JokerHand(t.Hand), Bet: t.Bet))
            .OrderBy(handBet => handBet.Hand)
            .Select((handBet, rank) => (rank + 1) * handBet.Bet)
            .Sum();

        return (p1, p2);
    }

    protected Hand JokerHand(Hand hand)
    {
        var numJokers = hand.Cards.Where(c => c == JOKER).Count();
        var groups = hand.Cards
           .Where(c => c != JOKER)
           .GroupBy(c => c)
           .Select(group => (Card: group.Key, Count: group.Count()))
           .OrderByDescending(t => t.Count)
           .ToList();

        var kind = Hand.HandKind.HighCard;
        if (numJokers == 5) kind = Hand.HandKind.FiveOfAKind;
        else if (numJokers == 4) kind = Hand.HandKind.FiveOfAKind;
        else if (numJokers == 3)
        {
            if (groups[0].Count == 2) kind = Hand.HandKind.FiveOfAKind;
            else kind = Hand.HandKind.FourOfAKind;
        }
        else if (numJokers == 2)
        {
            if (groups[0].Count == 3) kind = Hand.HandKind.FiveOfAKind;
            else if (groups[0].Count == 2) kind = Hand.HandKind.FourOfAKind;
            else kind = Hand.HandKind.ThreeOfAKind;
        }
        else if (numJokers == 1)
        {
            if (groups[0].Count == 4) kind = Hand.HandKind.FiveOfAKind;
            else if (groups[0].Count == 3) kind = Hand.HandKind.FourOfAKind;
            else if (groups[0].Count == 2 && groups[1].Count == 2) kind = Hand.HandKind.FullHouse;
            else if (groups[0].Count == 2) kind = Hand.HandKind.ThreeOfAKind;
            else kind = Hand.HandKind.OnePair;
        }
        else
        {
            // Same as other hand
            kind = hand.Kind;
        }

        return new Hand
        {
            Kind = kind,
            Cards = hand.Cards.Select(c => c == JOKER ? 1 : c).ToArray()
        };
    }

    [Fact]
    public void TestCompareHands()
    {
        Assert.True(new Hand { Kind = Hand.HandKind.FiveOfAKind } > new Hand { Kind = Hand.HandKind.FourOfAKind });
        Assert.True(new Hand { Kind = Hand.HandKind.ThreeOfAKind } < new Hand { Kind = Hand.HandKind.FiveOfAKind });

        Assert.True(new Hand { Kind = Hand.HandKind.FiveOfAKind, Cards = [12] } > new Hand { Kind = Hand.HandKind.FiveOfAKind, Cards = [4] });
        Assert.True(new Hand { Kind = Hand.HandKind.FullHouse, Cards = [5, 3] } < new Hand { Kind = Hand.HandKind.FullHouse, Cards = [5, 6] });
    }

    [Fact]
    public void TestJokerKind()
    {
        var originalHand = new Hand { Kind = Hand.HandKind.OnePair, Cards = [11, 7, 12, 5, 11] };
        var jokerHand = JokerHand(originalHand);
        Assert.Equal(Hand.HandKind.ThreeOfAKind, jokerHand.Kind);
    }
}
