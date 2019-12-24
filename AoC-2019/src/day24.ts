import { countTrue, parseData, range, repeat, sum, surroundingCoords } from "./common";
import { Stats } from "fs";

const grid = parseData("data/day24.data", l => l.split(""));

const BUG = "#";
const EMPTY = ".";

type Grid = Array<string[]>;

const width = grid[0].length;
const height = grid.length;

const bugAt = (x: number, y: number, state: Grid) =>
    x >= 0 && x < width && y >= 0 && y < height && state[y][x] === BUG;

const surroundingBugs = (x: number, y: number, state: Grid) =>
    countTrue(...surroundingCoords(x, y).map(([x, y]) => bugAt(x, y, state)));

function step(current: Grid): Grid {
    return current.map((row, y) => row.map((thing, x) => {
        const numBugsAround = surroundingBugs(x, y, current);
        return thing === BUG
            ? (numBugsAround === 1 ? BUG : EMPTY)
            : (numBugsAround === 1 || numBugsAround === 2 ? BUG : EMPTY);
    }));
}

const rating = (grid: Grid) => sum(grid.map((row, y) => sum(row.map((cell, x) => cell === EMPTY ? 0 : 2 ** (y * width + x)))));

const seen = new Set<number>();
let state = grid;
while (!seen.has(rating(state))) {
    seen.add(rating(state));
    state = step(state);
}
console.log(`Part 1: ${rating(state)}`);

// Part 2
const bugAtLevel = (x: number, y: number, level: number, state: Map<number, Grid>) =>
    state.has(level)
        ? (x=== 2 && y === 2 ? false : bugAt(x, y, state.get(level)!))
        : false;

const surroundingBugsRecursive = (x: number, y: number, level: number, state: Map<number, Grid>) =>
    countTrue(...surroundingCoords(x, y).map(([x, y]) => bugAtLevel(x, y, level, state)))
    + (y === 0 && bugAtLevel(2, 1, level - 1, state) ? 1 : 0)
    + (y === 4 && bugAtLevel(2, 3, level - 1, state) ? 1 : 0)
    + (x === 0 && bugAtLevel(1, 2, level - 1, state) ? 1 : 0)
    + (x === 4 && bugAtLevel(3, 2, level - 1, state) ? 1 : 0)
    + (x === 2 && y === 1 ? countTrue(...range(0, 4).map(x => bugAtLevel(x, 0, level + 1, state))) : 0)
    + (x === 2 && y === 3 ? countTrue(...range(0, 4).map(x => bugAtLevel(x, 4, level + 1, state))) : 0)
    + (x === 1 && y === 2 ? countTrue(...range(0, 4).map(y => bugAtLevel(0, y, level + 1, state))) : 0)
    + (x === 3 && y === 2 ? countTrue(...range(0, 4).map(y => bugAtLevel(4, y, level + 1, state))) : 0);

function stepRecursive(level: number, states: Map<number, Grid>): Grid {
    const current = states.get(level)!;
    return current.map((row, y) => row.map((thing, x) => {
        const numBugsAround = surroundingBugsRecursive(x, y, level, states);
        return x === 2 && y === 2
            ? EMPTY
            : thing === BUG
                ? (numBugsAround === 1 ? BUG : EMPTY)
                : (numBugsAround === 1 || numBugsAround === 2 ? BUG : EMPTY);
    }));
}

const iterations = 200;

const emptyGrid = repeat([".",".",".",".","."], 5);

let states = new Map<number, Grid>();
states.set(0, grid);
range(1, Math.ceil(iterations / 2)).forEach(l => states.set(l, emptyGrid));
range(-1, -Math.ceil(iterations / 2)).forEach(l => states.set(l, emptyGrid));

range(1, iterations).forEach(_ => {
    const newStates = new Map<number, Grid>();

    states.forEach((state, level) => newStates.set(level, stepRecursive(level, states)));

    states = newStates;
});

const bugsInGrid = (grid: Grid) => sum(grid.map(row => countTrue(...row.map(c => c === BUG))));
const countBugs = (states: Map<number, Grid>) => sum([...states.values()].map(s => bugsInGrid(s)));

console.log(`Part 2: ${countBugs(states)}`);
