import { execSync } from "child_process";
import { writeFileSync } from "fs";
import { binaryMaximize, binaryMinimize, parseData, unique } from "./common";

type Reagent = { count: number, chemical: string };
type Reaction = { in: Reagent[], out: Reagent }

function parseReagent(line: string): Reagent {
    const parts = line.trim().split(" ");
    return { count: parseInt(parts[0]), chemical: parts[1] };
}
function parseReaction(line: string): Reaction {
    const parts = line.split("=>");
    return { in: parts[0].split(",").map(parseReagent), out: parseReagent(parts[1]) }
}

const reactions = parseData("data/day14.data", parseReaction);

const chemicals = unique(reactions.map(r => r.out.chemical).concat("ORE"));
const chemicalVars = chemicals.map(c => `(declare-const ${c} Int)`);

const formulaVars = reactions.map((_, i) => `(declare-const f${i} Int)`);
const formulaConstraints = reactions.map((r, i) => `(assert (= ${r.out.chemical} (* ${r.out.count} f${i})))`);

const findFormulaCounts = (chemical: string) =>
    reactions.map((r, i) => [i, r.in.find(c => c.chemical === chemical)])
        .filter(([_, c]) => c !== undefined) as Array<[number, Reagent]>;

const chemicalConstraints = chemicals.filter(c => c !== "FUEL")
    .map(c => `(assert (>= ${c} (+ ${findFormulaCounts(c).map(r => `(* ${r[1].count} f${r[0]})`).join(" ")})))`);

const tryOreValue = (value: number) => {
    try {
        const fileContents = [
            ...chemicalVars,
            ...formulaVars,
            ...formulaConstraints,
            ...chemicalConstraints,
            "(assert (= FUEL 1))",
            `(assert (<= ORE ${value}))`,
            "(check-sat)",
            "(get-model)"
        ].join("\n");

        writeFileSync("day14.smt2", fileContents);
        execSync("z3 day14.smt2");
        return true; 
    } catch {
        return false
    }
};

console.log(`Part 1: ${binaryMinimize(0, 1000000, tryOreValue)}`);

const tryFuelValue = (value: number) => {
    try {
        const fileContents = [
            ...chemicalVars,
            ...formulaVars,
            ...formulaConstraints,
            ...chemicalConstraints,
            `(assert (>= FUEL ${value}))`,
            "(assert (<= ORE 1000000000000))",
            "(check-sat)",
            "(get-model)"
        ].join("\n");

        writeFileSync("day14.smt2", fileContents);
        execSync("z3 day14.smt2");
        return true; 
    } catch {
        return false
    }
};

console.log(`Part 2: ${binaryMaximize(0, 1000000000000, tryFuelValue)}`);
