import { splice } from "./common";

export type ProgramState = Readonly<{
    done?: true,
    waiting?: true,
    memory: number[];
    instructionPointer: number;
    input: number[];
    output: number[];
}>;

const getDigitAt = (value: number, index: number) => Math.floor(value / Math.pow(10,  index)) % 10;

function getParameterValue(index: number, state: ProgramState): number {
    const parameterMode = getDigitAt(state.memory[state.instructionPointer], index + 2);
    const value = state.memory[state.instructionPointer + index + 1];
    return parameterMode === 0
        ? state.memory[value]
        : value;
}

function add(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const sum = noun + verb;
    return {
        memory: splice(state.memory, state.memory[state.instructionPointer + 3], 1, sum),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    }
}

function multiply(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const product = noun * verb;
    return {
        memory: splice(state.memory, state.memory[state.instructionPointer + 3], 1, product),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    }
}

function consumeInput(state: ProgramState): ProgramState {
    const noun = state.memory[state.instructionPointer + 1];
    return state.input.length == 0
        ? wait(state)    
        : {
            memory: splice(state.memory, noun, 1, state.input[0]),
            instructionPointer: state.instructionPointer + 2,
            input: state.input.slice(1),
            output: state.output,
        }
}

function wait(state: ProgramState): ProgramState {
    return {
        waiting: true,
        memory: state.memory,
        instructionPointer: state.instructionPointer,
        input: state.input,
        output: state.output,
    }
}

function output(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    return {
        memory: state.memory,
        instructionPointer: state.instructionPointer + 2,
        input: state.input,
        output: [...state.output, noun],
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
    }
}

function lessThan(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const result = noun < verb ? 1 : 0;
    return {
        memory: splice(state.memory, state.memory[state.instructionPointer + 3], 1, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    }
}

function equals(state: ProgramState): ProgramState {
    const noun = getParameterValue(0, state);
    const verb = getParameterValue(1, state);
    const result = noun === verb ? 1 : 0;
    return {
        memory: splice(state.memory, state.memory[state.instructionPointer + 3], 1, result),
        instructionPointer: state.instructionPointer + 4,
        input: state.input,
        output: state.output,
    }
}

function terminate(state: ProgramState): ProgramState {
    return { 
        done: true, 
        instructionPointer: state.instructionPointer,
        memory: state.memory,
        input: state.input, 
        output: state.output
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
        case 99: return terminate(state)
        default: return error(state, `Unknown opCode ${opCode}`);
    }
}

export function execute(state: ProgramState): ProgramState {
    const nextState = handleNextInstruction(state);
    return nextState.done || nextState.waiting
        ? nextState
        : execute(nextState);
}

export const programFromMemoryAndInput = (memory: number[], input: number[]) => 
    ({ memory, instructionPointer: 0, input: input, output: [] });

export const addProgramInput = (state: ProgramState, ...input: number[]) =>
    ({
        memory: state.memory,
        instructionPointer: state.instructionPointer,
        input: [...state.input, ...input],
        output: state.output
    });