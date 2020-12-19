import { countTrue, parseData, sum } from "./common";

const input = parseData("data/day11.data", l => l);

type Coord = [number, number];
enum Change {
    Occupy,
    Empty,
    NoChange
}
type ChangeFunc = (seats: string[], x: number, y: number) => Change;

function seatOccupied(seats: string[], [x, y]: Coord): boolean {
    if (x < 0 || x >= seats[0].length) return false;
    if (y < 0 || y >= seats.length) return false;

    return seats[y][x] === "#";
}

function adjacentCoords([x, y]: Coord): Coord[] {
    return [[x - 1, y], [x + 1, y], [x, y - 1], [x, y + 1], [x + 1, y + 1], [x + 1, y - 1], [x - 1, y + 1], [x - 1, y - 1]];
}

function surroundingFilledSeats(seats: string[], x: number, y: number): number {
    return countTrue(...adjacentCoords([x, y]).map(c => seatOccupied(seats, c)))
}

function predictChange(seats: string[], x: number, y: number): Change {
    const surroundingFilled = surroundingFilledSeats(seats, x, y);
    if (seats[y][x] === "L" && surroundingFilled === 0) {
        return Change.Occupy;
    } else if (seats[y][x] === "#" && surroundingFilled >= 4) {
        return Change.Empty;
    } else {
        return Change.NoChange;
    }
}

function simulate(seats: string[], changeFunc: ChangeFunc): [string[], number] {
    const newSeats: string[][] = [];
    let changedSeats = 0;

    const height = seats.length;
    const width = seats[0].length;

    for (let y = 0; y < height; y++) {
        newSeats[y] = [];
        for (let x = 0; x < width; x++) {
            if (seats[y][x] === ".") {
                newSeats[y][x] = ".";
            } else {
                const change = changeFunc(seats, x, y);
                if (change === Change.Empty) {
                    newSeats[y][x] = "L";
                    changedSeats++;
                } else if (change === Change.Occupy) {
                    newSeats[y][x] = "#";
                    changedSeats++;
                } else  {
                    newSeats[y][x] = seats[y][x];
                }
            }
        }
    }
    return [newSeats.map(s => s.join("")), changedSeats];
}

function printSeats(seats: string[]) {
    for (const row of seats) {
        console.log(row);
    }
    console.log();
}

function simulateUntilNoChange(seats: string[], changeFunc: ChangeFunc): string[] {
    let [newSeats, changed] = simulate(seats, changeFunc);
    while (changed !== 0) {
        //printSeats(newSeats);
        [newSeats, changed] = simulate(newSeats, changeFunc);
    }
    //printSeats(newSeats);

    return newSeats;
}

const finalSeats = simulateUntilNoChange(input, predictChange);
const occupied = sum(finalSeats.flatMap(row => row.split("").map(c => c === "#" ? 1 : 0)));

console.log("Part 1", occupied);

// Part 2
function predictChange2(seats: string[], x: number, y: number): Change {
    const directions = [[0, -1], [1, -1], [1, 0], [1, 1], [0, 1], [-1, 1], [-1, 0], [-1, -1]];
    const seenOccupiedSeats = directions.filter(([dx, dy]) => canSeeVisibleSeat(seats, x, y, dx, dy)).length;

    if (seats[y][x] === "L" && seenOccupiedSeats === 0) {
        return Change.Occupy;
    } else if (seats[y][x] === "#" && seenOccupiedSeats >= 5) {
        return Change.Empty;
    } else {
        return Change.NoChange;
    }
}

function canSeeVisibleSeat(seats: string[], x: number, y: number, dx: number, dy: number) {
    const width = seats[0].length;
    const height = seats.length;

    let cx = x + dx;
    let cy = y + dy;

    while (cx >= 0 && cx < width && cy >= 0 && cy < height) {
        if (seats[cy][cx] === "#") {
            return true;
        }
        if (seats[cy][cx] === "L") {
            return false;
        }
        cx += dx;
        cy += dy;
    }
    return false;
}

const finalSeats2 = simulateUntilNoChange(input, predictChange2);
const occupied2 = sum(finalSeats2.flatMap(row => row.split("").map(c => c === "#" ? 1 : 0)));

console.log("Part 2", occupied2);