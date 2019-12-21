import { parseDataLine } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";

const memory = parseDataLine("data/day21.data", c => parseInt(c));

const springCode =
`NOT A T
NOT B J
OR J T
NOT C J
OR T J
AND D J
WALK
`.replace("\r", "");

const asciiToInts = (ascii: string) => [...ascii].map(c => c.charCodeAt(0));

const result = execute(programFromMemoryAndInput(memory, asciiToInts(springCode)));

if (result.output.length === 34) {
    console.log(`Part 1: ${result.output[33]}`);
} else {
    String.fromCharCode(...result.output).split("\n").forEach(l => console.log(l));
}

// Part 2
const springCode2 =
`NOT A T
NOT B J
OR J T
NOT C J
OR T J
AND D J
NOT H T
NOT T T
AND T J
NOT A T
OR T J
RUN
`.replace("\r", "");
const result2 = execute(programFromMemoryAndInput(memory, asciiToInts(springCode2)));
if (result2.output.length === 34) {
    console.log(`Part 1: ${result2.output[33]}`);
} else {
    String.fromCharCode(...result2.output).split("\n").forEach(l => console.log(l));
}