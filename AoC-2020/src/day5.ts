import { maxItem, parseData, range, sum, toLookUp } from "./common";

const passes = parseData("data/day5.data", l => l);

// Part 1
function toBinary(str: string, char1: string): number {
    const len = str.length;
    return sum(str.split("").map((c, i) => c === char1 ? Math.pow(2, len - 1 - i) : 0));
}

function findSeat(pass: string): [number, number, number] {
    const row = toBinary(pass.slice(0, 7), "B");
    const column = toBinary(pass.slice(7), "R");
    return [row, column, row * 8 + column];
}

console.log("Part 1:", maxItem(passes.map(findSeat), ([r, c, id]) => id));

// Part 2
const seats = passes.map(findSeat).map(([r, c, id]) => id).sort((a, b) => a - b);
const lookup = toLookUp(seats, s => s);
const missing = range(seats[0], seats[seats.length - 1]).find(s => lookup[s] === undefined);

console.log("Part 2:", missing);