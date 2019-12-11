import { parseDataLine, range } from "./common";
import { addProgramInput, execute, programFromMemoryAndInput, ProgramState } from "./intcode";

const memory = parseDataLine("data/day11.data",parseInt);

const enum Direction {
    Up, Right, Down, Left
}

// Part 1
const cellHash = (x: number, y: number) => `${x};${y}`;

function nextDirection(currentDirection: Direction, instruction: number): Direction {
    return (currentDirection + (instruction * 2 - 1) + 4) % 4;
}

function moveInDirection(x: number, y: number, direction: Direction): [number, number] {
    switch (direction) {
        case Direction.Up: return [x, y - 1];
        case Direction.Down: return [x, y + 1];
        case Direction.Left: return [x - 1, y];
        case Direction.Right: return [x + 1, y];
    }
}

function paintRoutine(program: ProgramState): Map<string, number> {
    let x = 0;
    let y = 0;
    let direction = Direction.Up;
    const paintedPanels = new Map<string, number>();

    while (!program.done) {
        program = execute(program);
        paintedPanels.set(cellHash(x, y), program.output[program.output.length - 2]);

        // Move to new square
        direction = nextDirection(direction, program.output[program.output.length - 1]);
        [x, y] = moveInDirection(x, y, direction);

        // Provide color of current square to program
        const currentSquareColor = paintedPanels.has(cellHash(x, y))
            ? paintedPanels.get(cellHash(x, y))!
            : 0;

        if (program.done) {
            break;
        }

        program = addProgramInput(program, currentSquareColor)
    }

    return paintedPanels;
}

const p1Panels = paintRoutine(programFromMemoryAndInput(memory, [0]));
console.log(`Part 1: ${p1Panels.size}`);

// Part 2
const p2Panels = paintRoutine(programFromMemoryAndInput(memory, [1]));

// Print output
console.log(`Part 2:`);
const getColor = (x: number, y: number) => p2Panels.get(cellHash(x, y)) === 1 ? "#" : " ";
for (let y = 0; y < 6; y++) {
    console.log(range(0, 39).map(x => getColor(x, y)).join(""));
}
