namespace AoC2023;

using TData = (Day19.Workflow[] Workflows, Day19.Part[] Parts);

public partial class Day19(ITestOutputHelper output) : AoCSolution<int, long, TData>(output)
{
    public record struct Workflow
    {
        public string Name;
        public WorkflowRule[] Rules;
    }

    public record struct WorkflowRule
    {
        public WorkflowRuleCondition? Condition;
        public string Target;
    }

    public record struct WorkflowRuleCondition
    {
        public char Variable;
        public char Comparison;
        public int Value;

        public WorkflowRuleCondition Opposite => Comparison == '>' ?
            new WorkflowRuleCondition
            {
                Variable = Variable,
                Comparison = '<',
                Value = Value + 1
            } : new WorkflowRuleCondition
            {
                Variable = Variable,
                Comparison = '>',
                Value = Value - 1
            };

        public override string ToString()
        {
            return $"{Variable}{Comparison}{Value}";
        }
    }

    public record struct Part(int X, int M, int A, int S)
    {
        public readonly bool SatisfiesCondition(WorkflowRuleCondition condition)
            => (condition.Variable, condition.Comparison) switch
            {
                ('x', '>') => X > condition.Value,
                ('x', '<') => X < condition.Value,
                ('m', '>') => M > condition.Value,
                ('m', '<') => M < condition.Value,
                ('a', '>') => A > condition.Value,
                ('a', '<') => A < condition.Value,
                ('s', '>') => S > condition.Value,
                ('s', '<') => S < condition.Value,
                _ => throw new Exception("Not possible")
            };
    }

    public record struct PartRange(Part Min, Part Max)
    {
        public readonly long Possibilities => Math.Max(0L, Max.X - Min.X - 1)
            * Math.Max(0L, Max.M - Min.M - 1)
            * Math.Max(0L, Max.A - Min.A - 1)
            * Math.Max(0L, Max.S - Min.S - 1);

        public PartRange ApplyCondition(WorkflowRuleCondition condition)
            => (condition.Variable, condition.Comparison) switch
            {
                ('x', '<') => new PartRange(Min, Max with { X = condition.Value }),
                ('x', '>') => new PartRange(Min with { X = condition.Value }, Max),
                ('m', '<') => new PartRange(Min, Max with { M = condition.Value }),
                ('m', '>') => new PartRange(Min with { M = condition.Value }, Max),
                ('a', '<') => new PartRange(Min, Max with { A = condition.Value }),
                ('a', '>') => new PartRange(Min with { A = condition.Value }, Max),
                ('s', '<') => new PartRange(Min, Max with { S = condition.Value }),
                ('s', '>') => new PartRange(Min with { S = condition.Value }, Max),
                _ => throw new Exception("Not possible")
            };
    }

    protected override TData LoadData()
    {
        var blocks = LoadLineBlocksFromFile("day19.txt");
        var workflows = blocks[0].Select(l =>
        {
            var opening = l.IndexOf('{');
            return new Workflow
            {
                Name = l[..opening],
                Rules = l[(opening + 1)..(l.Length - 1)].Split(",").Select(r =>
                {
                    var spl = r.Split(":");
                    if (spl.Length == 2)
                    {
                        var comparisonIndex = spl[0].IndexOf('<');
                        if (comparisonIndex == -1) comparisonIndex = spl[0].IndexOf('>');

                        return new WorkflowRule
                        {
                            Condition = new WorkflowRuleCondition
                            {
                                Variable = spl[0][0],
                                Comparison = spl[0][comparisonIndex],
                                Value = int.Parse(spl[0][(comparisonIndex + 1)..])
                            },
                            Target = spl[1]
                        };
                    }
                    else
                    {
                        return new WorkflowRule
                        {
                            Target = r
                        };
                    }
                }).ToArray()
            };
        }).ToArray();
        var ratings = blocks[1].Select(l =>
        {
            var nums = l.Substring(0, l.Length - 1).Split(",").Select(p => int.Parse(p.Split("=")[1]));
            return new Part
            {
                X = nums.ElementAt(0),
                M = nums.ElementAt(1),
                A = nums.ElementAt(2),
                S = nums.ElementAt(3)
            };
        }).ToArray();
        return (workflows, ratings);
    }

    protected override (int p1, long p2) Solve()
    {
        var workflows = Data.Workflows.ToDictionary(wf => wf.Name);

        var p1 = 0;
        foreach (var part in Data.Parts)
        {
            var rule = "in";
            while (rule != "R" && rule != "A")
            {
                rule = ApplyWorkflow(part, workflows[rule]);
            }
            if (rule == "A")
            {
                p1 += part.X + part.M + part.A + part.S;
            }
        }

        long Possibilities(string rule, PartRange range)
        {
            if (rule == "A") return range.Possibilities;
            if (rule == "R") return 0L;

            var result = 0L;
            foreach (var r in workflows[rule].Rules)
            {
                if (r.Condition.HasValue)
                {
                    result += Possibilities(r.Target, range.ApplyCondition(r.Condition.Value));
                    range = range.ApplyCondition(r.Condition.Value.Opposite);
                }
                else
                {
                    result += Possibilities(r.Target, range);
                }
            }
            return result;
        }

        var p2 = Possibilities("in", new PartRange(new Part(0, 0, 0, 0), new Part(4001, 4001, 4001, 4001)));

        return (p1, p2);
    }

    private static string ApplyWorkflow(Part part, Workflow workflow)
    {
        foreach (var rule in workflow.Rules)
        {
            if (rule.Condition == null || part.SatisfiesCondition(rule.Condition.Value))
            {
                return rule.Target;
            }
        }

        throw new Exception("Not possible");
    }
}
