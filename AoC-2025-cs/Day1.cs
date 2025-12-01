namespace AoC_2025_cs;

public class Day1
{
    [Fact]
    public async Task P1P2()
    {
        var input = await File.ReadAllLinesAsync("../../../data/day1.txt", TestContext.Current.CancellationToken);

        var dial = 50;  
        var p1 = 0;  
        var p2 = 0;    

        foreach (var instruction in input)
        {
            if (instruction.Length < 2) continue;

            var direction = instruction[0];
            var ticks = int.Parse(instruction[1..]);

            if (direction == 'R')
            {
                for (var i =0; i < ticks; i++)
                {
                    dial++;
                    dial %= 100;

                    if (dial == 0)
                    {
                        p2++;
                    }   
                }
            }
            else
            {
                for (var i =0; i < ticks; i++)
                {
                    dial--;
                    if (dial < 0)
                    {
                        dial += 100;
                    }

                    if (dial == 0)
                    {
                        p2++;
                    }   
                }
            }

            if (dial == 0)
            {
                p1++;
            }

            //Console.WriteLine($"{dial}");
        }

        Console.WriteLine($"p1: {p1}");
        Console.WriteLine($"p2: {p2}");
    }
}
