using System.Data;

namespace AoC_2025_cs;

public class Day2
{
    [Fact]
    public async Task P1P2()
    {
        //var input = "11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124";
        var input ="328412-412772,1610-2974,163-270,7693600637-7693779967,352-586,65728-111612,734895-926350,68-130,183511-264058,8181752851-8181892713,32291-63049,6658-12472,720-1326,21836182-21869091,983931-1016370,467936-607122,31-48,6549987-6603447,8282771161-8282886238,7659673-7828029,2-18,7549306131-7549468715,3177-5305,20522-31608,763697750-763835073,5252512393-5252544612,6622957-6731483,9786096-9876355,53488585-53570896";
        var ranges = input.Split(",").Select(static r =>
        {
            var split = r.Split("-");
            return (first: long.Parse(split[0]), last: long.Parse(split[1]));
        });

        long p1 = 0;
        long p2 = 0;

        foreach (var range in ranges)
        {
            for (long id = range.first; id <= range.last; id++)
            {
                if (IsSilly(id))
                {
                    //Console.WriteLine(id);
                    p1 += id;
                }
                if (IsSillyP2(id))
                {
                    Console.WriteLine(id);
                    p2 += id;
                }
            }
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }

    private bool IsSilly(long id)
    {
        var str = id.ToString();
        if (str.Length % 2 == 1) return false;
        return str.Substring(0, str.Length / 2) == str.Substring(str.Length / 2);
    }

    private bool IsSillyP2(long id)
    {
        var str = id.ToString();

        var maxChunk = str.Length / 2;

        for (var size = maxChunk; size > 0; size--)
        {
            if (str.Length % size != 0) continue;
            var first = str[..size];
            var equal = true;
            for (var i = size; i < str.Length; i += size)
            {
                var t = str[i..(i + size)];
                if (t != first)
                {
                    equal = false;
                    break;
                }
            }

            if (equal) return true;
        }

        return false;
    }
}
