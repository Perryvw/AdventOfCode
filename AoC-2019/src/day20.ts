import { bfs, join, parseData, range, surroundingCoords, log } from "./common";

const maze = parseData("data/day20.data", l => [...l.replace(/[\r\n]+/, "")], false);

const width = maze[0].length;
const height = maze.length;

type Position = [number, number];
type NamedPosition = [string, Position];
const outerNamedPoints = [
    ...range(2, width - 2).filter(x => maze[0][x] !== " ")
        .map<NamedPosition>(x => [maze[0][x] + maze[1][x], [x, 2]]),
    ...range(2, width - 2).filter(x => maze[height - 1][x] !== " ")
        .map<NamedPosition>(x => [maze[height - 2][x] + maze[height - 1][x], [x, height - 3]]),
    ...range(2, height - 2).filter(y => maze[y][0] !== " ")
        .map<NamedPosition>(y => [maze[y][0] + maze[y][1], [2, y]]),
    ...range(2, height - 2).filter(y => maze[y][width - 2] !== " ")
        .map<NamedPosition>(y => [maze[y][width - 2] + maze[y][width - 1], [width - 3, y]])
];

const halfHeight = Math.floor(height / 2);
const innerRadius = range(2, 50).findIndex(x => maze[halfHeight][x] !== "." && maze[halfHeight][x] !== "#");

const innerNamedPoints = [
    ...range(2 + innerRadius, width - innerRadius - 3).filter(x => maze[height - 3 - innerRadius][x] !== " ")
        .map<NamedPosition>(x => [maze[height - 4 - innerRadius][x] + maze[height - 3 - innerRadius][x], [x, height - 2 - innerRadius]]),
    ...range(2 + innerRadius, width - innerRadius - 3).filter(x => maze[innerRadius + 2][x] !== " ")
        .map<NamedPosition>(x => [maze[innerRadius + 2][x] + maze[innerRadius + 3][x], [x, innerRadius + 1]]),
    ...range(2 + innerRadius, height - innerRadius - 3).filter(y => maze[y][width - innerRadius - 4] !== " ")
        .map<NamedPosition>(y => [maze[y][width - innerRadius - 4] + maze[y][width - innerRadius - 3], [width - innerRadius - 2, y]]),
    ...range(2 + innerRadius, height - innerRadius - 3).filter(y => maze[y][innerRadius + 2] !== " ")
        .map<NamedPosition>(y => [maze[y][innerRadius + 2] + maze[y][innerRadius + 3], [innerRadius + 1, y]])
];

const namedPoints = [...outerNamedPoints, ...innerNamedPoints]

const teleporters = join(namedPoints, namedPoints, (p1, p2) => p1 !== p2 && p1[0] === p2[0], (p1, p2) => [p1[1], p2[1]]);

const startPos = namedPoints.find(([name]) => name === "AA")![1];
const endPos = namedPoints.find(([name]) => name === "ZZ")![1];

const hash = ([x, y]: Position) => x * 1000 + y;
const endHash = hash(endPos);

const teleporterMap = new Map(teleporters.map(([from, to]) => [hash(from), to]));
const tryTeleport = (pos: Position): Position => teleporterMap.get(hash(pos)) || pos;

const shortestPath = bfs([startPos],
    p => hash(p) === endHash,
    state => [tryTeleport(state), 
                ...surroundingCoords(state[0], state[1])
                    .filter(([x, y]) => maze[y][x] === ".")],
    hash);

console.log(shortestPath!.length - 1);

// Part 2
const connectOut = join(outerNamedPoints, innerNamedPoints, (p1, p2) => p1[0] === p2[0], (p1, p2) => [p1[1], p2[1]]);
const connectIn = join(innerNamedPoints, outerNamedPoints, (p1, p2) => p1[0] === p2[0], (p1, p2) => [p1[1], p2[1]]);

const connectOutMap = new Map(connectOut.map(([from, to]) => [hash(from), to]));
const connectInMap = new Map(connectIn.map(([from, to]) => [hash(from), to]));

type PositionAtLevel = [Position, number];

function tryChangeLevel([pos, level]: PositionAtLevel): PositionAtLevel {
    const posHash = hash(pos);
    return level < 0 && connectOutMap.has(posHash) ? [connectOutMap.get(posHash)!, level + 1]
        : connectInMap.has(posHash) ? [connectInMap.get(posHash)!, level - 1]
        : [pos, level];
}

const startHash = hash(startPos);

const shortestPath2 = bfs<PositionAtLevel>([[startPos, 0]],
    ([p, l]) => l === 0 && hash(p) === endHash,
    state => [tryChangeLevel(state), 
                ...surroundingCoords(state[0][0], state[0][1])
                    .filter(([x, y]) => maze[y][x] === ".")
                    .filter(pos => state[1] === 0 || !(hash(pos) === endHash || hash(pos) === startHash))
                    .map(pos => [pos, state[1]] as PositionAtLevel)],
    ([pos, level]) => hash(pos) + 10000000 * level);

console.log(shortestPath2!.length - 1);