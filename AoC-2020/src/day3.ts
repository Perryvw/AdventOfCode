import { product, readLines } from "./common";

const lines = readLines("data/day3.data");

// Part 1
function numTreesHit(lines: string[], slopeX: number, slopeY: number, currentX = 0): number {
    if (slopeY  >= lines.length) return 0;

    const nextX = (currentX + slopeX) % lines[0].length;
    const hit = lines[slopeY][nextX] === "#" ? 1 : 0;
    return hit + numTreesHit(lines.slice(slopeY), slopeX, slopeY, nextX);
}

console.log("Part 1:", numTreesHit(lines, 3, 1));

// Part 2
const result = product([
    numTreesHit(lines, 1, 1),
    numTreesHit(lines, 3, 1),
    numTreesHit(lines, 5, 1),
    numTreesHit(lines, 7, 1),
    numTreesHit(lines, 1, 2),
]);

console.log("Part 2:", result);