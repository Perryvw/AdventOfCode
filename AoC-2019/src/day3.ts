import { readLines, combinations, isBetween, range, enumerate, sum } from "./common";

interface Move {
    direction: "U" | "R" | "D" | "L",
    distance: number
}

interface LineSegment {
    fromX: number;
    fromY: number;
    toX: number;
    toY: number
}

const lines = readLines("data/day3.data");
const parseLine = (str: string) => str.split(",").map(v => ({ direction: v[0], distance: parseInt(v.substr(1))}) as Move);
const line1 = parseLine(lines[0]);
const line2 = parseLine(lines[1]);

// Part 1
function getLineSegments(currentX: number, currentY: number, moves: Move[]): LineSegment[] {
    if (moves.length === 0) {
        return [];
    } else {
        const move = moves[0];

        const newX = move.direction === "L" ? currentX - move.distance
            : move.direction === "R" ? currentX + move.distance
            : currentX;
        const newY = move.direction === "U" ? currentY + move.distance
            : move.direction === "D" ? currentY - move.distance
            : currentY;

        const segment = { fromX: currentX, fromY: currentY, toX: newX, toY: newY };
        return [segment, ...getLineSegments(newX, newY, moves.slice(1))];
    }
}

const isVertical = (segment: LineSegment) => segment.fromX === segment.toX;
const haveIntersection = (s1: LineSegment, s2: LineSegment) => isVertical(s1) 
        ? isBetween(s1.fromX, Math.min(s2.fromX, s2.toX), Math.max(s2.fromX, s2.toX)) 
            && isBetween(s2.fromY, Math.min(s1.fromY, s1.toY), Math.max(s1.fromY, s1.toY))
        : isBetween(s2.fromX, Math.min(s1.fromX, s1.toX), Math.max(s1.fromX, s1.toX))
            && isBetween(s1.fromY, Math.min(s2.fromY, s2.toY), Math.max(s2.fromY, s2.toY));

function getIntersection(s1: LineSegment, s2: LineSegment): [number, number] {
    return isVertical(s1)
        ? [s1.fromX, s2.fromY]
        : [s2.fromX, s1.fromY];
}

const manhattanDistance = ([x, y]: [number, number]) => Math.abs(x) + Math.abs(y);

const line1Segments = getLineSegments(0, 0, line1);
const line2Segments = getLineSegments(0, 0, line2);

const findIntersections = (l1: LineSegment[], l2: LineSegment[]) =>
    combinations(l1, l2)
        .filter(([s1, s2]) => haveIntersection(s1, s2))
        .map(([s1, s2]) => getIntersection(s1, s2));

const intersections = findIntersections(line1Segments, line2Segments)
    .sort((a, b) => manhattanDistance(a) - manhattanDistance(b));

console.log(`Part 1: ${manhattanDistance(intersections[1])}`);

// Part 2
const findEnumeratedIntersections = (l1: LineSegment[], l2: LineSegment[]) =>
    combinations(enumerate(l1), enumerate(l2))
        .filter(([[_, s1], [__, s2]]) => haveIntersection(s1, s2))
        .map(([[i1, s1], [i2, s2]]) => [i1, i2, getIntersection(s1, s2)] as [number, number, [number, number]]);

const segmentLength = (segment: LineSegment) => isVertical(segment)
    ? Math.abs(segment.fromY - segment.toY)
    : Math.abs(segment.fromX - segment.toX);
const pathLength = (line: LineSegment[]) => sum(line.map(segmentLength));

function stepsToPoint(line: LineSegment[], segmentIndex: number, x: number, y: number): number {
    const segment = line[segmentIndex];
    return pathLength(line.slice(0, segmentIndex)) + Math.abs(segment.fromX - x) + Math.abs(segment.fromY - y);
}

const scoredIntersections = findEnumeratedIntersections(line1Segments, line2Segments)
    .map(([i1, i2, [x, y]]) => [stepsToPoint(line1Segments, i1, x, y) + stepsToPoint(line2Segments, i2, x, y), [x, y]] as [number, [number, number]])
    .sort(([score1, _], [score2, __]) => score1 - score2);

console.log(`Part 2: ${scoredIntersections[1][0]}`);
