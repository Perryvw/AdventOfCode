import { parseDataLine, splice } from "./common";
import { addProgramInput, execute, programFromMemoryAndInput, ProgramState } from "./intcode";

const initialMemory = parseDataLine("data/day13.data", parseInt);

// Part 1
const initialOutput = execute(programFromMemoryAndInput(initialMemory, [])).output;
const tileTypes = initialOutput.filter((_, i) => i % 3 === 2);
console.log(`Part 1: ${tileTypes.filter(t => t === 2).length}`);

// Part 2
type Tile = [number, number, number];

function lastTileOfType(type: number, state: ProgramState) {
    const index = state.output
        .filter((_, i) => i % 3 === 2)
        .lastIndexOf(type) * 3;
    return state.output.slice(index, index + 3) as Tile;
}
const paddleX = (state: ProgramState) => lastTileOfType(3, state)[0];
const ballX = (state: ProgramState) => lastTileOfType(4, state)[0];

const hackedProgram = programFromMemoryAndInput(splice(initialMemory, 0, 1, 2), []);
const result = execute(hackedProgram, state => {
    const px = paddleX(state);
    const bx = ballX(state);
    return px < bx ? addProgramInput(state, 1)
        : px > bx ? addProgramInput(state, -1)
        : addProgramInput(state, 0);
});

const lastXCoord = (state: ProgramState) => state.output
    .filter((_, i) => i % 3 === 0)
    .lastIndexOf(-1) * 3;
const score = (state: ProgramState) => state.output[lastXCoord(state) + 2];
const finalScore = score(result);
console.log(`Part 2: ${finalScore}`);