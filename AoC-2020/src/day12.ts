import { parseData, posMod } from "./common";

type InstructionType = "N" | "S" | "E" | "W" | "L" | "R" | "F";
type Instruction = { instruction: InstructionType, value: number };
const instructions = parseData("data/day12.data", l => ({ instruction: l[0] as InstructionType, value: parseInt(l.slice(1)) }));

// Part 1
enum Direction {
    North, East, South, West
}

function moveInDirection(x: number, y: number, direction: Direction, distance: number): [number, number] {
    switch (direction) {
        case Direction.North: return [x, y + distance];
        case Direction.South: return [x, y - distance];
        case Direction.West: return [x - distance, y];
        case Direction.East: return [x + distance, y];
    }
}

function followInstruction(x: number, y: number, direction: Direction, instruction: Instruction): [number, number, Direction] {
    switch (instruction.instruction) {
        case "N": return [...moveInDirection(x, y, Direction.North, instruction.value), direction];
        case "S": return [...moveInDirection(x, y, Direction.South, instruction.value), direction];
        case "W": return [...moveInDirection(x, y, Direction.West, instruction.value), direction];
        case "E": return [...moveInDirection(x, y, Direction.East, instruction.value), direction];
        case "R": return [x, y, posMod(direction + instruction.value / 90, 4)];
        case "L": return [x, y, posMod(direction - instruction.value / 90, 4)];
        case "F": return [...moveInDirection(x, y, direction, instruction.value), direction];
    }
}

const finalPos = instructions.reduce(([x, y, dir], instruction) => followInstruction(x, y, dir, instruction), [0, 0, Direction.East]);
const result = Math.abs(finalPos[0]) + Math.abs(finalPos[1]);
console.log("Part 1:", result);

// Part 2
function rotateVector(x: number, y: number, direction: number): [number, number] {
    switch (posMod(direction, 4)) {
        case 0: return [x, y];
        case 1: return [y, -x];
        case 2: return [-x, -y];
        case 3: return [-y, x];
        default:
            throw new Error(`Unknown direction ${posMod(direction, 4)}`);
    }
}

function followInstruction2(x: number, y: number, wpx: number, wpy: number, instruction: Instruction): [number, number, number, number] {
    switch (instruction.instruction) {
        case "N": return [x, y, ...moveInDirection(wpx, wpy, Direction.North, instruction.value)];
        case "S": return [x, y, ...moveInDirection(wpx, wpy, Direction.South, instruction.value)];
        case "W": return [x, y,...moveInDirection(wpx, wpy, Direction.West, instruction.value)];
        case "E": return [x, y,...moveInDirection(wpx, wpy, Direction.East, instruction.value)];
        case "R": return [x, y, ...rotateVector(wpx, wpy, instruction.value / 90)];
        case "L": return [x, y, ...rotateVector(wpx, wpy, -instruction.value / 90)];
        case "F": return [x + instruction.value * wpx, y + instruction.value * wpy, wpx, wpy];
    }
}

const finalPos2 = instructions.reduce(([x, y, wpx, wpy], instruction) => followInstruction2(x, y, wpx, wpy, instruction), [0, 0, 10, 1]);
const result2 = Math.abs(finalPos2[0]) + Math.abs(finalPos2[1]);
console.log("Part 2:", result2);
