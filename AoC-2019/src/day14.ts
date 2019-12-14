import { execSync } from "child_process";
import { writeFileSync } from "fs";
import { parseData, unique } from "./common";

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

const z3FileWithTarget = (target: number) => [
        ...chemicalVars,
        ...formulaVars,
        ...formulaConstraints,
        ...chemicalConstraints,
        "(assert (= FUEL 1))",
        `(assert (<= ORE ${target}))`,
        "(check-sat)",
        "(get-model)"
    ].join("\n");

function binaryMinimize(lower: number, upper: number): number {
    const half = Math.floor((lower + upper) / 2);
    if (lower > upper) return half;
    writeFileSync("day14.smt2", z3FileWithTarget(half));
    try {
        execSync("z3 day14.smt2");
        return lower < upper
            ? binaryMinimize(lower, half - 1)
            : upper;
    } catch {
        // Unsat
        return lower < upper
            ? binaryMinimize(half + 1, upper)
            : lower;
    };
}

console.log(`Part 1: ${binaryMinimize(0, 1000000)}`);

const z3FileWithTargetMaximize = (target: number) => [
    ...chemicalVars,
    ...formulaVars,
    ...formulaConstraints,
    ...chemicalConstraints,
    `(assert (>= FUEL ${target}))`,
    "(assert (<= ORE 1000000000000))",
    "(check-sat)",
    "(get-model)"
].join("\n");

function binaryMaximize(lower: number, upper: number): number {
    const half = Math.floor((lower + upper) / 2);
    if (lower > upper) return half;
    writeFileSync("day14.smt2", z3FileWithTargetMaximize(half));
    try {
        execSync("z3 day14.smt2");
        return lower < upper
            ? binaryMaximize(half + 1, upper)
            : upper;
    } catch {
        // Unsat
        return lower < upper
            ? binaryMaximize(lower, half - 1)
            : lower;
    };
}

console.log(`Part 2: ${binaryMaximize(0, 1000000000000)}`);
