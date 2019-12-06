"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const directions = common_1.readLines("data/day1.data")[0].split(", ");
const posModulo = (n, mod) => n < 0
    ? (n % mod) + mod
    : n % mod;
function doMove(position, move) {
    const turnDirection = move[0] == "L" ? -1 : 1;
    const newOrientation = posModulo(position.orientation + turnDirection, 4);
    const moveDistance = parseInt(move.substr(1));
    const newX = newOrientation == 1 ? position.x + moveDistance
        : newOrientation == 3 ? position.x - moveDistance
            : position.x;
    const newY = newOrientation == 0 ? position.y + moveDistance
        : newOrientation == 2 ? position.y - moveDistance
            : position.y;
    return {
        x: newX,
        y: newY,
        orientation: newOrientation
    };
}
const finalLocation = directions.reduce(doMove, { x: 0, y: 0, orientation: 0 });
const distance = Math.abs(finalLocation.x) + Math.abs(finalLocation.y);
console.log(`Part 1: ${distance}`);
// Part 2
function moveRecursive(position, moves, seen) {
    const newPos = doMove(position, moves.shift());
    if (newPos.x != position.x) {
        const dir = newPos.x > position.x ? 1 : -1;
        for (let x = position.x; x != newPos.x; x += dir) {
            const posHash = `${x};${newPos.y}`;
            if (seen.has(posHash)) {
                return { x, y: newPos.y, orientation: 0 };
            }
            else {
                seen.add(posHash);
            }
        }
    }
    else {
        const dir = newPos.y > position.y ? 1 : -1;
        for (let y = position.y; y != newPos.y; y += dir) {
            const posHash = `${newPos.x};${y}`;
            if (seen.has(posHash)) {
                return { x: newPos.x, y, orientation: 0 };
            }
            else {
                seen.add(posHash);
            }
        }
    }
    return moveRecursive(newPos, moves, seen);
}
const finalLocation2 = moveRecursive({ x: 0, y: 0, orientation: 0 }, directions, new Set());
const distance2 = Math.abs(finalLocation2.x) + Math.abs(finalLocation2.y);
console.log(`Part 2: ${distance2}`);
