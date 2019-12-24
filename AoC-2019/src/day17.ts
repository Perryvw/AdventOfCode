import { countTrue, sum, parseDataLine, range, minItem, splice, maxItem, log, last } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";

const VOID = ".";
const SCAFFOLD = "#";

/*const result = `..#..........
..#..........
#######...###
#.#...#...#.#
#############
..#...#...#..
..#####...^..`.split("").map(s => s.charCodeAt(0));*/

const memory = parseDataLine("data/day17.data", parseInt);
const result = execute(programFromMemoryAndInput(memory, [])).output;

const outString = String.fromCharCode(...result);

const map = outString.trim().split("\n").map(row => row.split(""));
const width = map[0].length;
const height = map.length;

function countSurroundingNonVoid(x: number, y: number) {
    const above = y > 0 && map[y - 1][x] !== VOID;
    const left = x > 0 && map[y][x - 1] !== VOID;
    const below = y < height - 1 && map[y + 1][x] !== VOID;
    const right = x < width - 1 && map[y][x + 1] !== VOID;

    return countTrue(above, left, below, right);
}

const isIntersection = (x: number, y: number) =>
    map[y][x] !== VOID
        ? countSurroundingNonVoid(x, y) > 2
        : false;

const intersections = map.flatMap((row, y) => row.map((_, x) => [x, y] as const))
    .filter(([x, y]) => isIntersection(x, y));

// Part 1
console.log(`Part 1 ${sum(intersections.map(([x, y]) => x * y))}`);

// Part 2
const start: [number, number] = [outString.replace(/\n/g, "").indexOf("^") % width, Math.floor(outString.indexOf("^") / width)];

const tileAt = ([x, y]: [number, number]) =>
    y < 0 || y >= map.length ? VOID
    : x < 0 || x >= width ? VOID
    : map[y][x];

const moveDirection = (x: number, y: number, direction: number): [number, number] =>
    direction === 0 ? [x, y - 1]
    : direction === 1 ? [x + 1, y]
    : direction === 2 ? [x, y + 1]
    : [x - 1, y];

function tracePath([x, y]: [number, number], direction: number) : Array<"R" | "L" | number> {
    const left = (direction + 3) % 4;
    const right = (direction + 1) % 4;
    const canMoveForward = tileAt(moveDirection(x, y, direction)) === SCAFFOLD;
    const canMoveLeft = tileAt(moveDirection(x, y, left)) === SCAFFOLD;
    const canMoveRight = tileAt(moveDirection(x, y, right)) === SCAFFOLD;

    const mergeForward = () => {
        const next = tracePath(moveDirection(x, y, direction), direction);
        return next[0] !== "R" && next[0] !== "L" && next[0] !== undefined
            ? [next[0] + 1, ...next.slice(1)]
            : [1, ...next];
    }

    return canMoveForward ? mergeForward()
        : canMoveLeft ? ["L", ...tracePath([x, y], left)]
        : canMoveRight ? ["R", ...tracePath([x, y], right)]
        : [];
}

// Get robot path
//console.log(`Path: ${tracePath(start, 0).join()}`);

// Solved by hand
const input = 
`A,B,B,A,C,A,A,C,B,C
R,8,L,12,R,8
R,12,L,8,R,10
R,8,L,8,L,8,R,8,R,10
n
`.split("").map(s => s.charCodeAt(0));

const result2 = execute(programFromMemoryAndInput(splice(memory, 0, 1, 2), input));
console.log(`Part 2: ${last(result2.output)}`);
