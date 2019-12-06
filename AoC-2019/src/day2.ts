import { parseDataLine, splice, updateArray, range, combinations } from "./common";

const program = parseDataLine("data/day2.data", parseInt);

function handleOpCode(code: number, index: number, memory: number[]): number {
    return code == 1 ? memory[memory[index + 1]] + memory[memory[index + 2]]
        : code == 2 ? memory[memory[index + 1]] * memory[memory[index + 2]]
        : -1;
}

function execute(index: number, memory: number[]): number[] {
    const opCode = memory[index];
    return opCode == 99
        ? memory
        : execute(index + 4, updateArray(memory, memory[index + 3], handleOpCode(opCode, index, memory)));
}

const p1Program = splice(program, 1, 2, 12, 2);
const result = execute(0, p1Program);
console.log(`Part 1: ${result[0]}`);

// Part 2
const xVals = range(0, 99);
const yVals = range(0, 99);
const coords = combinations(xVals, yVals);
const [x, y] = coords.find(([x, y]) => execute(0, splice(program, 1, 2, x, y))[0] === 19690720)!;
console.log(`Part 2: ${x*100 + y}`);
