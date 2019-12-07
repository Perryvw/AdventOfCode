import { parseDataLine } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";

const instructions = parseDataLine("data/day5.data", parseInt);

// Part1
const p1Program = programFromMemoryAndInput(instructions, [1]);
const result = execute(p1Program);
console.log(`Part 1: ${result.output[result.output.length - 1]}`);

// Part 2
const p2Program = programFromMemoryAndInput(instructions, [5]);
const result2 = execute(p2Program);
console.log(`Part 2: ${result2.output}`);
