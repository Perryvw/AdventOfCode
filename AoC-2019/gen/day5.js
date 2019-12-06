"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const instructions = common_1.parseDataLine("data/day5.data", parseInt);
const getDigitAt = (value, index) => Math.floor(value / Math.pow(10, index)) % 10;
function getParameterValue(index, state) {
    const parameterMode = getDigitAt(state.memory[state.instructionPointer], index + 2);
    const value = state.memory[state.instructionPointer + index + 1];
    return parameterMode === 0
        ? state.memory[value]
        : value;
}
function add(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const sum = noun + verb;
    return {
        memory: common_1.splice(state.memory, state.memory[state.instructionPointer + 3], 1, sum),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    };
}
function multiply(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const product = noun * verb;
    return {
        memory: common_1.splice(state.memory, state.memory[state.instructionPointer + 3], 1, product),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    };
}
function consumeInput(state) {
    const noun = state.memory[state.instructionPointer + 1];
    return {
        memory: common_1.splice(state.memory, noun, 1, state.input[0]),
        instructionPointer: state.instructionPointer + 2,
        input: state.input.slice(1),
        output: state.output,
    };
}
function output(state) {
    const noun = getParameterValue(0, state);
    return {
        memory: state.memory,
        instructionPointer: state.instructionPointer + 2,
        input: state.input,
        output: [...state.output, noun],
    };
}
function jumpIfTrue(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    return {
        memory: state.memory,
        instructionPointer: noun !== 0 ? verb : state.instructionPointer + 3,
        input: state.input,
        output: state.output,
    };
}
function jumpIfFalse(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    return {
        memory: state.memory,
        instructionPointer: noun === 0 ? verb : state.instructionPointer + 3,
        input: state.input,
        output: state.output,
    };
}
function lessThan(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const result = noun < verb ? 1 : 0;
    return {
        memory: common_1.splice(state.memory, state.memory[state.instructionPointer + 3], 1, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    };
}
function equals(state) {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const result = noun === verb ? 1 : 0;
    return {
        memory: common_1.splice(state.memory, state.memory[state.instructionPointer + 3], 1, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    };
}
function terminate(state) {
    return {
        done: true,
        instructionPointer: state.instructionPointer,
        memory: state.memory,
        input: state.input,
        output: state.output
    };
}
function error(state, message) {
    console.error(message);
    return terminate(state);
}
function handleNextInstruction(state) {
    const opCode = state.memory[state.instructionPointer] % 100;
    switch (opCode) {
        case 1: return add(state);
        case 2: return multiply(state);
        case 3: return consumeInput(state);
        case 4: return output(state);
        case 5: return jumpIfTrue(state);
        case 6: return jumpIfFalse(state);
        case 7: return lessThan(state);
        case 8: return equals(state);
        case 99: return terminate(state);
        default: return error(state, `Unknown opCode ${opCode}`);
    }
}
function execute(state) {
    const nextState = handleNextInstruction(state);
    return nextState.done
        ? nextState
        : execute(nextState);
}
const programFromMemoryAndInput = (memory, input) => ({ memory, instructionPointer: 0, input: input, output: [] });
// Part1
const p1Program = programFromMemoryAndInput(instructions, [1]);
const result = execute(p1Program);
console.log(`Part 1: ${result.output[result.output.length - 1]}`);
// Part 2
const p2Program = programFromMemoryAndInput(instructions, [5]);
const result2 = execute(p2Program);
console.log(`Part 2: ${result2.output}`);
