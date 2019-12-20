import { parseData, log, last, splice, uniqueOn } from "./common";

const caveMap = parseData("data/day18.data", l => l.split(""));
const availableKeys = "abcdefghijklmnopqrstuvwxyz".split("").filter(c => caveMap.some(row => row.includes(c)));

const startPos = caveMap.flatMap((row, y) => row.map((c, x) => [x, y] as const))
    .find(([x, y]) => caveMap[y][x] === "@")!;

const isLowerCaseLetter = (c: string) => (c.charCodeAt(0) >= "a".charCodeAt(0) && c.charCodeAt(0) <= "z".charCodeAt(0));
const isUpperCaseLetter = (c: string) => c.charCodeAt(0) >= "A".charCodeAt(0) && c.charCodeAt(0) <= "Z".charCodeAt(0);

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
const nextStateAt2 = (state: BfsState2, robotIndex: number, position: Position) => ({
    positions: splice(state.positions, robotIndex, 1, position) as RobotPositions,
    keys: isLowerCaseLetter(caveMap[position[1]][position[0]]) && !hasKey2(state, caveMap[position[1]][position[0]])
        ? [...state.keys, caveMap[position[1]][position[0]]].sort()
        : state.keys
});

const stateHash = (state: BfsState2) => `${state.positions};${state.keys}`;

// Even slower, doesnt even finish for examples
/*const pathThroughAll2 = bfs<BfsState2>(
    [{ positions: startPos2 as RobotPositions, keys: [] }],
    state => state.keys.length === availableKeys2.length,
    state => uniqueOn(state.positions.flatMap((pos, i) => surroundingCoords(pos)
                .filter(([x, y]) => caveMap[y][x] !== "#")
                .filter(([x, y]) => !(isUpperCaseLetter(caveMap[y][x]) && !hasKey2(state, caveMap[y][x])))
                .map(newPos => nextStateAt2(state, i, newPos))), stateHash),
    stateHash);

console.log(pathThroughAll2!.length - 1);*/
