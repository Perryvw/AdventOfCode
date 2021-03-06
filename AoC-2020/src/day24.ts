import { parseData, toBag } from "./common";

type Coord = { e: number, se: number, sw: number, w: number, nw: number, ne: number };
function parseCoord(line: string): Coord {
    const coord = { e: 0, se: 0, sw: 0, w: 0, nw: 0, ne: 0 };
    for (let i = 0; i < line.length; i++) {
        if (line[i] === "e") coord.e++;
        else if (line[i] === "w") coord.w++;
        else if (line[i] === "s") {
            i++;
            if (line[i] === "w") coord.sw++;
            if (line[i] === "e") coord.se++;
        } else {
            i++;
            if (line[i] === "w") coord.nw++;
            if (line[i] === "e") coord.ne++;
        }
    }
    return coord;
}

function normalize(coord: Coord): [number, number] {
    return [coord.e + 0.5 * (coord.ne + coord.se) - coord.w - 0.5 * (coord.nw + coord.sw),
        0.5 * (coord.ne + coord.nw) - 0.5 * (coord.sw + coord.se)
    ];
}

const coords = parseData("data/day24.data", l => normalize(parseCoord(l)));

const hash = (x: number, y: number) => x * 100000 + y;

const bag = toBag(coords.map(([x, y]) => hash(x, y)));
const blackTiles1 = [...bag.entries()].filter(([h, count]) => count % 2 === 1);
console.log("Part 1:", blackTiles1.length);

// Part 2
function neighbours(x: number, y: number): Array<[number, number]> {
    return [[x + 1, y], [x - 1, y], [x + 0.5, y + 0.5], [x + 0.5, y - 0.5], [x - 0.5, y + 0.5], [x - 0.5, y - 0.5]];
}

const tilehashes = coords.map(c => [hash(c[0], c[1]), c] as const);
let blackTiles = new Map<number, [number, number]>(tilehashes.filter(([tilehash, _]) => bag.get(tilehash)! % 2 === 1));

function numBlackNeighbours(x: number, y: number) {
    const tileNeighbours = neighbours(x, y);
    return tileNeighbours.filter(([nx, ny]) => blackTiles.has(hash(nx, ny))).length;
}

for (let i = 0; i < 100; i++) {
    const newBlack = new Map<number, [number, number]>();

    for (const tile of blackTiles.values()) {
        const tileNeighbours = neighbours(tile[0], tile[1]);
        const blackNeighbours = tileNeighbours.filter(([nx, ny]) => blackTiles.has(hash(nx, ny)));
        if (blackNeighbours.length === 1 || blackNeighbours.length === 2) {
            newBlack.set(hash(tile[0], tile[1]), tile);
        }

        const whiteNeighbours = tileNeighbours.filter(([nx, ny]) => !blackTiles.has(hash(nx, ny)));
        for (const neighbour of whiteNeighbours) {
            if (numBlackNeighbours(neighbour[0], neighbour[1]) === 2) {
                newBlack.set(hash(neighbour[0], neighbour[1]), neighbour);
            }
        }
    }

    blackTiles = newBlack;
}

console.log("Part 2:", blackTiles.size);
