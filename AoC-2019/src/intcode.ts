import { splice, resize } from "./common";

export type ProgramState = Readonly<{
    done?: true,
    waiting?: true,
    memory: number[];
    instructionPointer: number;
    relativeBase: number;
    input: number[];
    output: number[];
}>;

const getDigitAt = (value: number, index: number) => Math.floor(value / Math.pow(10,  index)) % 10;
const writeToMemory = (memory: number[], index: number, value: number) => {
    return index < memory.length
        ? splice(memory, index, 1, value)
        : splice(resize(memory, index, 0), index, 1, value);
}

function getParameterValue(index: number, state: ProgramState): number {
    const parameterMode = getDigitAt(state.memory[state.instructionPointer], index + 2);
    const value = state.memory[state.instructionPointer + index + 1];
    switch (parameterMode) {
        case 0: return state.memory[value] || 0;
        case 1: return value;
        case 2: return state.memory[value + state.relativeBase] || 0;
        default: return value;
    };
}

function getTargetParameter(index: number, state: ProgramState) {
    const parameterMode = getDigitAt(state.memory[state.instructionPointer], index + 2);
    const value = state.memory[state.instructionPointer + index + 1];
    return parameterMode == 2
        ? value + state.relativeBase
        : value;
}

function add(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const target = getTargetParameter(2, state);
    const sum = noun + verb;
    return {
        memory: writeToMemory(state.memory, target, sum),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function multiply(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const target = getTargetParameter(2, state);
    const product = noun * verb;
    return {
        memory: writeToMemory(state.memory, target, product),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function consumeInput(state: ProgramState): ProgramState {
    const target = getTargetParameter(0, state);
    return state.input.length == 0
        ? wait(state)    
        : {
            memory: writeToMemory(state.memory, target, state.input[0]),
            instructionPointer: state.instructionPointer + 2,
            input: state.input.slice(1),
            output: state.output,
            relativeBase: state.relativeBase,
        }
}

function wait(state: ProgramState): ProgramState {
    return {
        waiting: true,
        memory: state.memory,
        instructionPointer: state.instructionPointer,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function output(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    return {
        memory: state.memory,
        instructionPointer: state.instructionPointer + 2,
        input: state.input,
        output: [...state.output, noun],
        relativeBase: state.relativeBase,
    }
}

function jumpIfTrue(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    return {
        memory: state.memory,
        instructionPointer: noun !== 0 ? verb : state.instructionPointer + 3,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function jumpIfFalse(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    return {
        memory: state.memory,
        instructionPointer: noun === 0 ? verb : state.instructionPointer + 3,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function lessThan(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const target = getTargetParameter(2, state);
    const result = noun < verb ? 1 : 0;
    return {
        memory: writeToMemory(state.memory, target, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function equals(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const target = getTargetParameter(2, state);
    const result = noun === verb ? 1 : 0;
    return {
        memory: writeToMemory(state.memory, target, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase,
    }
}

function increaseRelativeBase(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    return {
        memory: state.memory,
        instructionPointer: state.instructionPointer + 2,
        input: state.input,
        output: state.output,
        relativeBase: state.relativeBase + noun,
    }
}

function terminate(state: ProgramState): ProgramState {
    return { 
        done: true, 
        instructionPointer: state.instructionPointer,
        memory: state.memory,
        input: state.input, 
        output: state.output,
        relativeBase: state.relativeBase,
    };
}

function error(state: ProgramState, message: string): ProgramState {
    console.error(message);
    return terminate(state);
}

function handleNextInstruction(state: ProgramState): ProgramState {
    const opCode = state.memory[state.instructionPointer] % 100;
    switch (opCode) {
        case 1: return add(state)
        case 2: return multiply(state)
        case 3: return consumeInput(state)
        case 4: return output(state)
        case 5: return jumpIfTrue(state)
        case 6: return jumpIfFalse(state)
        case 7: return lessThan(state)
        case 8: return equals(state)
        case 9: return increaseRelativeBase(state)
        case 99: return terminate(state)
        default: return error(state, `Unknown opCode ${opCode}`);
    }
}

export function execute(state: ProgramState, inputProvider = (state: ProgramState) => state): ProgramState {
    let nextState = handleNextInstruction(state);
    while (!nextState.done && !nextState.waiting) {
        nextState = handleNextInstruction(nextState);
        if (nextState.waiting) {
            nextState = inputProvider(nextState);
        }
    }
    return nextState;
    // No tail call optimization -> causes stack overflows T_T
    /*const nextState = handleNextInstruction(state);
    return nextState.done || nextState.waiting
        ? nextState
        : execute(nextState);*/
}

export const programFromMemoryAndInput = (memory: number[], input: number[]) => 
    ({ memory, instructionPointer: 0, relativeBase: 0, input, output: [] });

export const addProgramInput = (state: ProgramState, ...input: number[]) =>
    ({
        memory: state.memory,
        instructionPointer: state.instructionPointer,
        input: [...state.input, ...input],
        output: state.output,
        relativeBase: state.relativeBase,
    });

export const clearOutput = (state: ProgramState) => 
    ({
        memory: state.memory,
        instructionPointer: state.instructionPointer,
        input: state.input,
        output: [],
        relativeBase: state.relativeBase,
    });