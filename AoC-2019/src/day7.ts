import { parseDataLine, permutations, max, last } from "./common";
import { execute, programFromMemoryAndInput, ProgramState, addProgramInput } from "./intcode";

const amplifierControllerSoftware = parseDataLine("data/day7.data", parseInt);

const phaseSettings = permutations([0,1,2,3,4]);

const thrusterWithInput = (input: number[]) => programFromMemoryAndInput(amplifierControllerSoftware, input);

function thrustForSetting(setting: number[]): number {
    const out1 = execute(thrusterWithInput([setting[0], 0])).output[0];
    const out2 = execute(thrusterWithInput([setting[1], out1])).output[0];
    const out3 = execute(thrusterWithInput([setting[2], out2])).output[0];
    const out4 = execute(thrusterWithInput([setting[3], out3])).output[0];
    return execute(thrusterWithInput([setting[4], out4])).output[0];
}

const maxThrust = max(phaseSettings.map(thrustForSetting));
console.log(`Part 1: ${maxThrust}`);

// Part 2
const phaseSettings2 = permutations([5,6,7,8,9]);

function thrustForSetting2(setting: number[]): number {
    const initialPrograms = [
        thrusterWithInput([setting[0], 0]),
        thrusterWithInput([setting[1]]),
        thrusterWithInput([setting[2]]),
        thrusterWithInput([setting[3]]),
        thrusterWithInput([setting[4]]),
    ];

    function recurse(programs: ProgramState[]): number {
        const state1 = execute(programs[0]);
        const state2 = execute(addProgramInput(programs[1], last(state1.output)));
        const state3 = execute(addProgramInput(programs[2], last(state2.output)));
        const state4 = execute(addProgramInput(programs[3], last(state3.output)));
        const state5 = execute(addProgramInput(programs[4], last(state4.output)));

        return state5.done
            ? last(state5.output)
            : recurse([addProgramInput(state1, last(state5.output)), state2, state3, state4, state5]);
    }

    return recurse(initialPrograms);
}

const maxThrust2 = max(phaseSettings2.map(thrustForSetting2));
console.log(`Part 2: ${maxThrust2}`);
