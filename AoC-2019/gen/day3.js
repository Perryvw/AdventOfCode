"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const lines = common_1.readLines("data/day3.data");
const parseLine = (str) => str.split(",").map(v => ({ direction: v[0], distance: parseInt(v.substr(1)) }));
const line1 = parseLine(lines[0]);
const line2 = parseLine(lines[1]);
// Part 1
function getLineSegments(currentX, currentY, moves) {
    if (moves.length === 0) {
        return [];
    }
    else {
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
const isVertical = (segment) => segment.fromX === segment.toX;
const haveIntersection = (s1, s2) => isVertical(s1)
    ? common_1.isBetween(s1.fromX, Math.min(s2.fromX, s2.toX), Math.max(s2.fromX, s2.toX))
        && common_1.isBetween(s2.fromY, Math.min(s1.fromY, s1.toY), Math.max(s1.fromY, s1.toY))
    : common_1.isBetween(s2.fromX, Math.min(s1.fromX, s1.toX), Math.max(s1.fromX, s1.toX))
        && common_1.isBetween(s1.fromY, Math.min(s2.fromY, s2.toY), Math.max(s2.fromY, s2.toY));
function getIntersection(s1, s2) {
    return isVertical(s1)
        ? [s1.fromX, s2.fromY]
        : [s2.fromX, s1.fromY];
}
const manhattanDistance = ([x, y]) => Math.abs(x) + Math.abs(y);
const line1Segments = getLineSegments(0, 0, line1);
const line2Segments = getLineSegments(0, 0, line2);
const findIntersections = (l1, l2) => common_1.combinations(l1, l2)
    .filter(([s1, s2]) => haveIntersection(s1, s2))
    .map(([s1, s2]) => getIntersection(s1, s2));
const intersections = findIntersections(line1Segments, line2Segments)
    .sort((a, b) => manhattanDistance(a) - manhattanDistance(b));
console.log(`Part 1: ${manhattanDistance(intersections[1])}`);
// Part 2
const findEnumeratedIntersections = (l1, l2) => common_1.combinations(common_1.enumerate(l1), common_1.enumerate(l2))
    .filter(([[_, s1], [__, s2]]) => haveIntersection(s1, s2))
    .map(([[i1, s1], [i2, s2]]) => [i1, i2, getIntersection(s1, s2)]);
const segmentLength = (segment) => isVertical(segment)
    ? Math.abs(segment.fromY - segment.toY)
    : Math.abs(segment.fromX - segment.toX);
const pathLength = (line) => common_1.sum(line.map(segmentLength));
function stepsToPoint(line, segmentIndex, x, y) {
    const segment = line[segmentIndex];
    return pathLength(line.slice(0, segmentIndex)) + Math.abs(segment.fromX - x) + Math.abs(segment.fromY - y);
}
const scoredIntersections = findEnumeratedIntersections(line1Segments, line2Segments)
    .map(([i1, i2, [x, y]]) => [stepsToPoint(line1Segments, i1, x, y) + stepsToPoint(line2Segments, i2, x, y), [x, y]])
    .sort(([score1, _], [score2, __]) => score1 - score2);
console.log(`Part 2: ${scoredIntersections[1][0]}`);
