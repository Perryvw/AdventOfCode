import { parseData, sum } from "./common";

function parseBag(line: string): [string, Array<[number, string]>] {
    const bag = /^(.*) bags contain/.exec(line)![1];
    const contains = line.split("contain")[1].split(",");

    const childBags = (b: string): [number, string] => {
        const match = /(\d+) ([^\.,]+) bag/.exec(b);
        return [parseInt(match![1]), match![2]];
    }

    return (contains.length === 1 && contains[0].includes("no "))
        ? [bag, []]
        : [bag, contains.map(childBags)]
}

const rules = parseData("data/day7.data", parseBag);

// Part 1
// Create inverse adjecency list
const invAdjList = new Map<string, string[]>();
for (const [bag, children] of rules) {
    for (const [count, childbag] of children) {
        if (invAdjList.has(childbag)) {
            invAdjList.get(childbag)!.push(bag);
        } else {
            invAdjList.set(childbag, [bag]);
        }
    }
}

// Find parents
function parents(key: string): string[] {
    if (!invAdjList.has(key)) return [];

    const directParents = invAdjList.get(key)!;
    return [...directParents, ...directParents.flatMap(parents)];
}

console.log("Part 1", new Set(parents("shiny gold")).size);

// Part 2
// Create forward adjecency list
const adjList = new Map<string, Array<[number, string]>>(rules);

function contents(key: string): number {
    return sum(adjList.get(key)!.map(([count, bag]) => count + count * contents(bag)));
}

console.log("Part 2", contents("shiny gold"));