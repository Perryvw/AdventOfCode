import { readData } from "./common";

const input = readData("data/day19.data");
const rules = input.split("\n\n")[0].split("\n");
const messages = input.split("\n\n")[1].split("\n");

const ruleMap = new Map(rules.map(r => {
    const [id, rule] = r.split(": ");
    const options = rule.split(" | ");
    return [id, options.map(p => p.split(" "))];
}));

function matchesRule(id: string, message: string): string[] {
    const patterns = ruleMap.get(id)!;
    return patterns.flatMap(p => matchesPattern(p, message)).filter(v => v !== undefined);
}

function matchesPattern(pattern: string[], message: string): string[] {
    if (pattern[0].startsWith(`"`)) {
        return message[0] === pattern[0][1]
            ? [message.slice(1)]
            : [];
    } else {
        let result = [message];
        for (const p of pattern) {
            result = result.flatMap(m => matchesRule(p, m));
        }
        return result;
    }
}

// Part 1
const result = messages.filter(m => matchesRule("0", m).includes(""));
console.log("Part 1:", result.length);

// Part 2
ruleMap.set("8", [["42"], ["42", "8"]]);
ruleMap.set("11", [["42", "31"], ["42", "11", "31"]]);

const result2 = messages.filter(m => matchesRule("0", m).includes(""));
console.log("Part 2:", result2.length);