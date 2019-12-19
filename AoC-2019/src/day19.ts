import { parseDataLine, range, binaryMinimize, binaryMaximize, log } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";

const memory = parseDataLine("data/day19.data", c => parseInt(c));

const getOutput = (x: number, y: number) => execute(programFromMemoryAndInput(memory, [x, y])).output[0];

// Part 1
const map = range(0, 49).map(y => range(0, 49).map(x => getOutput(x, y)));
console.log(`Part 1: ${map.flat(1).filter(v => v === 1).length}`);

// Part 2
const SQUARE_SIZE = 100;

const firstSquareAtLevel = (y: number) =>
    range(Math.floor(y / 1.3), y).find(xOffset => getOutput(xOffset, y) === 1)!;
const lastSquareAtLevel = (y: number, firstSquare: number) => 
    range(firstSquare, y).findIndex(xOffset => getOutput(xOffset, y) === 0) + firstSquare;
const widthAtLevel = (y: number) => {
    const firstSquare = firstSquareAtLevel(y);
    return lastSquareAtLevel(y, firstSquare) - firstSquare;
}

const squareFitsAtLevel = (y: number) =>
    widthAtLevel(y) - (firstSquareAtLevel(y + SQUARE_SIZE - 1) - firstSquareAtLevel(y)) >= SQUARE_SIZE;

const roughY = binaryMinimize(0, 4000, squareFitsAtLevel);
// Do a little backtracking because the transition is not immediate,
// i.e you can have true, true, true, true, false, true, false, false, false, false
const firstY = range(roughY - 10, roughY).find(squareFitsAtLevel)!;
const squareCoords = [firstSquareAtLevel(firstY + SQUARE_SIZE - 1), firstY];
console.log(`Part 2: ${squareCoords[0] * 10000 + squareCoords[1]}`);
