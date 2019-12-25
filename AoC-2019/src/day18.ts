import { parseData, log, last, splice, uniqueOn, bfs, surroundingCoords, toLookUp, range, sum } from "./common";
import * as Collections from "typescript-collections";

const caveMap = parseData("data/day18.data", l => l.split(""));
const availableKeys = "abcdefghijklmnopqrstuvwxyz".split("").filter(c => caveMap.some(row => row.includes(c)));

const startPos = caveMap.flatMap((row, y) => row.map((c, x) => [x, y] as const))
    .find(([x, y]) => caveMap[y][x] === "@")!;

const isLowerCaseLetter = (c: string) => (c.charCodeAt(0) >= "a".charCodeAt(0) && c.charCodeAt(0) <= "z".charCodeAt(0));
const isUpperCaseLetter = (c: string) => c.charCodeAt(0) >= "A".charCodeAt(0) && c.charCodeAt(0) <= "Z".charCodeAt(0);
const isLetter = (c: string) => isLowerCaseLetter(c) || isUpperCaseLetter(c);

type Position = readonly [number, number];
type BfsState = Readonly<{ position: Position, keys: string[] }>;

const hasKey = (state: BfsState, key: string) => state.keys.includes(key.toLowerCase());
const nextStateAt = (state: BfsState, position: Position) => ({
    position,
    keys: isLowerCaseLetter(caveMap[position[1]][position[0]]) && !hasKey(state, caveMap[position[1]][position[0]])
        ? [...state.keys, caveMap[position[1]][position[0]]].sort()
        : state.keys
});

// Very slow!
/*const pathThroughAll = bfs<BfsState>(
    [{ position: startPos, keys: [] }],
    state => state.keys.length === availableKeys.length,
    state => surroundingCoords(state.position)
                .filter(([x, y]) => caveMap[y][x] !== "#")
                .filter(([x, y]) => !(isUpperCaseLetter(caveMap[y][x]) && !hasKey(state, caveMap[y][x])))
                .map(pos => nextStateAt(state, pos)),
    state => `${state.position[0] * 1000 + state.position[1]};${state.keys}`);

console.log(pathThroughAll!.length - 1);*/

// Part 2
const caveMap2 = parseData("data/day18b.data", l => l.split(""));
const availableKeys2 = "abcdefghijklmnopqrstuvwxyz".split("").filter(c => caveMap2.some(row => row.includes(c)));
const startPos2 = caveMap2.flatMap((row, y) => row.map((c, x) => [x, y] as const))
    .filter(([x, y]) => caveMap2[y][x] === "@");

type RobotPositions = [Position, Position, Position, Position];
type BfsState2 = { positions: RobotPositions, keys: string[] };

const hasKey2 = (state: BfsState2, key: string) => state.keys.includes(key.toLowerCase());
const nextStateAt2 = (state: ExploreState, newPos: Position): ExploreState => ({
    position: newPos,
    previousLetter: isLetter(caveMap2[newPos[1]][newPos[0]]) ? caveMap2[newPos[1]][newPos[0]] : state.previousLetter,
    distance: isLetter(caveMap2[newPos[1]][newPos[0]]) ? 0 : state.distance + 1,
});

const stateHash = (state: ExploreState) => `${state.position};${state.previousLetter}`;

console.log(startPos2);

type Edge = [string, string];
type ExploreState = { position: Position, previousLetter: string, distance: number };

function findEdges(position: Position): Record<string, Record<string, number>> {
    const edges = new Map<string, number>();

    // Even slower, doesnt even finish for examples
    const pathThroughAll2 = bfs<ExploreState>(
        [{ position, previousLetter: "START", distance: 0 }],
        state => false,
        state => surroundingCoords(state.position[0], state.position[1])
                    .filter(([x, y]) => caveMap2[y][x] !== "#")
                    .map(newPos => {
                        if (isLetter(caveMap2[newPos[1]][newPos[0]]) && caveMap2[newPos[1]][newPos[0]] !== state.previousLetter) {
                            const edge = [state.previousLetter, caveMap2[newPos[1]][newPos[0]]].sort().toString();
                            if (!edges.has(edge)) {
                                edges.set(edge, state.distance + 1);
                            }
                        }
                        return nextStateAt2(state, newPos);
                    }),
        s => stateHash(s));

    const result: Record<string, Record<string, number>> = {};
    for (const [key, value] of edges.entries()) {
        const [fromkey, tokey] = key.split(",");
        if (!result[fromkey]) {
            result[fromkey] = {};
        }
        if (!result[tokey]) {
            result[tokey] = {};
        }
        result[fromkey][tokey] = value;
        result[tokey][fromkey] = value;
    }
    return result;
}

const edges = startPos2.map(pos => findEdges(pos));

type NodeWithCost = [string, number];
type SearchState = { states: [NodeWithCost, NodeWithCost, NodeWithCost, NodeWithCost], keys: string[] };
const start: SearchState = { states: [["START", 0], ["START", 0], ["START", 0], ["START", 0]], keys: [] };

function stepState(state: NodeWithCost, index: number, keys: string[]): Array<[NodeWithCost, string[]]> {
    const es = edges[index];
    const nextStates: Array<[NodeWithCost, string[]]> = [];
    for (const next in es[state[0]]) {
        if (isLowerCaseLetter(next) || (isUpperCaseLetter(next) && keys.includes(next.toLowerCase()))) {
            const nextKeys = (isLowerCaseLetter(next) && !keys.includes(next)) ? [next, ...keys] : keys;
            nextStates.push([[next, state[1] + es[state[0]][next]], nextKeys]);
        }
    }
    return nextStates;
}

function step(state: SearchState): SearchState[] {
    return range(0, 3).flatMap(i => 
        stepState(state.states[i], i, state.keys)
            .map(([node, keys]) => ({ states: splice(state.states, i, 1, node), keys } as SearchState)));
}

const cost = (state: SearchState) => sum(state.states.map(s => s[1]));

type BfsGoalPredicate<TState> = (state: TState) => boolean;
type BfsTransitionFunction<TState> = (currentStates: TState) => TState[];
type BfsHashFunction<TState> = (state: TState) => string | number;
export function dijkstras<TState>(
    initialState: TState[],
    goalReached: BfsGoalPredicate<TState>,
    nextStates: BfsTransitionFunction<TState>,
    costFunction: (path: TState[]) => number,
    hashFunction: BfsHashFunction<TState>
): TState[] | undefined {
    const seen = new Set<string | number>();
    const queue = new Collections.PriorityQueue<TState[]>((a, b) => costFunction(b) - costFunction(a));
    initialState.forEach(s => queue.enqueue([s]));
    while (!queue.isEmpty()) {
        const path = queue.dequeue()!;
        const state = last(path);
        if (goalReached(state)) {
            return path;
        }
        const hash = hashFunction(state);
        if (seen.has(hash)) {
            continue;
        }
        seen.add(hash);
        nextStates(state).map(newState => [...path, newState]).forEach(s => queue.enqueue(s));
    }
}

const result = dijkstras([start],
    state => state.keys.length === availableKeys2.length,
    step,
    states => cost(last(states)) - last(states).keys.length,
    state => `${state.states.map(s => s[0])},${state.keys.sort()}`);

console.log(last(result!));
console.log(cost(last(result!)));
