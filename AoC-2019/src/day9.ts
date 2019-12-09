import { parseDataLine } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";

const instructions = parseDataLine("data/day9.data", parseInt);

const result = execute(programFromMemoryAndInput(instructions, [1]));
console.log(`Part 1: ${result.output[0]}`);

const result2 = execute(programFromMemoryAndInput(instructions, [2]));
console.log(`Part 2: ${result2.output[0]}`);