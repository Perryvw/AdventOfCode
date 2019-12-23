import { parseDataLine, range, zip, toLookUp, partitionBySize, last } from "./common";
import { programFromMemoryAndInput, execute, addProgramInput, clearOutput } from "./intcode";

const program = parseDataLine("data/day23.data", c => parseInt(c));

const programs = range(0, 49).map(nId => programFromMemoryAndInput(program, [nId]));

let executionResults = programs.map(p => execute(p));

type OutPackage = [number, number, number];

let packageQueue = {} as Record<number, OutPackage[]>;

let NATPackage = [0, 0, 0] as OutPackage;
let seenNatY = new Set<number>();

while (true) {
    const inputPackages = range(0, 49).map(n => packageQueue[n] ? packageQueue[n].flatMap(p => [p[1], p[2]]) : [-1]);
    executionResults = zip(executionResults, inputPackages).map(([program, input]) => execute(addProgramInput(clearOutput(program), ...input)));

    const outputPackages = executionResults
        .flatMap(r => partitionBySize(r.output, 3) as OutPackage[])
        .filter(r => r.length > 0);

    packageQueue = toLookUp(outputPackages, p => p[0]);
    if (packageQueue[255]) {
        NATPackage = last(packageQueue[255]);
    }

    if (outputPackages.length === 0) {
        packageQueue = {[0]: [NATPackage]};
        if (seenNatY.size === 0) {
            console.log(`Part 1: ${NATPackage[2]}`);
        }
        if (seenNatY.has(NATPackage[2])) {
            console.log(`Part 2: ${NATPackage[2]}`);
            break;
        }
        seenNatY.add(NATPackage[2]);
    }
}
