"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const program = common_1.parseDataLine("data/day2.data", parseInt);
function handleOpCode(code, index, memory) {
    return code == 1 ? memory[memory[index + 1]] + memory[memory[index + 2]]
        : code == 2 ? memory[memory[index + 1]] * memory[memory[index + 2]]
            : -1;
}
function execute(index, memory) {
    const opCode = memory[index];
    return opCode == 99
        ? memory
        : execute(index + 4, common_1.updateArray(memory, memory[index + 3], handleOpCode(opCode, index, memory)));
}
const p1Program = common_1.splice(program, 1, 2, 12, 2);
const result = execute(0, p1Program);
console.log(`Part 1: ${result[0]}`);
// Part 2
const xVals = common_1.range(0, 99);
const yVals = common_1.range(0, 99);
const coords = common_1.combinations(xVals, yVals);
const [x, y] = coords.find(([x, y]) => execute(0, common_1.splice(program, 1, 2, x, y))[0] === 19690720);
console.log(`Part 2: ${x * 100 + y}`);
