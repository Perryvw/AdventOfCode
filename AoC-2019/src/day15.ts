import { parseDataLine, last, range } from "./common";
import { addProgramInput, execute, programFromMemoryAndInput, ProgramState } from "./intcode";

const enum Direction {
    North = 1,
    South = 2,
    West = 3,
    East = 4
}

const initialMemory = parseDataLine("data/day15.data", parseInt);
const program = programFromMemoryAndInput(initialMemory, [Direction.North]);

type Position = [number, number];

function move(x: number, y: number, direction: Direction): [number, number] {
    return direction === Direction.North ? [x, y + 1]
        : direction === Direction.South ? [x, y - 1]
        : direction === Direction.West ? [x - 1, y]
        : [x + 1, y];
}

const hash = ([x, y]: Position) => x * 1000000 + y;

type BFSState = [ProgramState, Position];

let finalLocation = [0, 0] as Position;

function explore(state: BFSState[], distance: number, seen: Map<number, number>): Map<number, number> {
    const toExplore = state.flatMap(([program, [x, y]]) => range(1, 4).map(direction => [program, x, y, direction] as const))
        .filter(([_, x, y, d]) => !seen.has(hash(move(x, y, d))));

    const newSeen = new Map(seen);
    const nextState = toExplore.map(([state, x, y, d]) => {
        const nextPos = move(x, y, d);
        const nextState = execute(addProgramInput(state, d));
        const result = last(nextState.output);
        if (result === 2) {
            finalLocation = nextPos;
            console.log(`Part 1: ${distance + 1}`);
        }
        newSeen.set(hash(nextPos), result);
        return result === 0
            ? undefined
            : [nextState, nextPos];
    }) as Array<BFSState | undefined>;

    return toExplore.length === 0
        ? seen
        : explore(nextState.filter(x => x !== undefined) as BFSState[], distance + 1, newSeen);
}

const map = explore([[program, [0, 0]]], 0, new Map<number, number>());
const seen = new Set<number>();
function furthestTile(x: number, y: number, distance: number): number
{
    if (seen.has(hash([x, y]))) return 0;
    seen.add(hash([x, y]));

    const tile = map.get(hash([x, y])) || 0;
    if (tile === 0) {
        return distance - 1;
    } else {
        return range(1, 4).reduce((maxDist, direction) => {
            const newPos = move(x, y, direction);
            return Math.max(maxDist, furthestTile(newPos[0], newPos[1], distance + 1)); 
        }, 0);
    }
}

console.log(`Part 2: ${furthestTile(finalLocation[0], finalLocation[1], 0)}`);
