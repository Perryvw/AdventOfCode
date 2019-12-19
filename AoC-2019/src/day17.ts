import { countTrue, sum, parseDataLine } from "./common";
import { execute, programFromMemoryAndInput } from "./intcode";
import * as fs from "fs";

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
fs.writeFileSync("mapOut.txt", outString);

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

console.log(intersections);

// Part 1
console.log(`Part 1 ${sum(intersections.map(([x, y]) => x * y))}`);

// Part 2

