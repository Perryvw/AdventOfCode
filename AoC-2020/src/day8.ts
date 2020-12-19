import { parseData } from "./common";

const instructions = parseData("data/day8.data", parseInstruction);

interface MachineState {
    instructionPointer: number;
    accumulator: number;
}

interface Instruction { 
    operator: string,
    value: number
};

function parseInstruction(s: string): Instruction {
    return {
        operator: s.substring(0, 3),
        value: parseInt(s.substr(4))
    };
}

function execute(state: MachineState, instruction: Instruction): MachineState {
    switch (instruction.operator) {
        case "acc": return {
            ...state,
            instructionPointer: state.instructionPointer + 1,
            accumulator: state.accumulator + instruction.value
        };
        case "jmp": return {
            ...state,
            instructionPointer: state.instructionPointer + instruction.value            
        };
        case "nop": return {
            ...state,
            instructionPointer: state.instructionPointer + 1
        }            
    }

    throw new Error(`unsupported operation: ${instruction.operator}`);
}

function initialMachineState(): MachineState {
    return { instructionPointer: 0, accumulator: 0 };
}

function runInstructions(ins: Instruction[]): { terminated: boolean, finalState: MachineState } {
    let state = initialMachineState();
    let seen = new Set<number>();
    while (!seen.has(state.instructionPointer)) {

        if (state.instructionPointer === ins.length) {
            return { terminated: true, finalState: state };
        }

        seen.add(state.instructionPointer);
        state = execute(state, ins[state.instructionPointer]);
    }

    return { terminated: false, finalState: state };
}

console.log("Part 1", runInstructions(instructions).finalState);

// Part 2
for (let i = 0; i < instructions.length; i++) {
    if (instructions[i].operator !== "nop" && instructions[i].operator !== "jmp") {
        continue;
    }

    const newInstructions = [...instructions];
    newInstructions[i] = { operator: instructions[i].operator === "nop" ? "jmp" : "nop", value: instructions[i].value };

    const { terminated, finalState } = runInstructions(newInstructions);
    if (terminated) {
        console.log("Part 2", i, finalState);
    }
}