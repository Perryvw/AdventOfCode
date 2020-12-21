import { posMod, product, range, readData, repeat } from "./common";

const input = readData("data/day20.data");

const reverse = (s: string) => s.split("").reverse().join("");

enum Direction { Up, Right, Down, Left }

class Tile {

    rotation = 0;
    flipped = false;
    position = [0,0];

    private edges: string[];

    private constructor(public id: string, private text: string[]) {
        const width = text[0].length;
        this.edges = [
            text[0], // top
            range(0, text.length - 1).map(i => text[i][width - 1]).join(""), // right
            reverse(text[text.length - 1]), // bottom
            reverse(range(0, text.length - 1).map(i => text[i][0]).join("")) // left
        ];
    }

    public static fromInput(inp: string[]): Tile {
        const id = inp[0].slice(5, -1);
        return new Tile(id, inp.slice(1));
    }

    getEdge(direction: Direction) {
        const index = posMod(direction - this.rotation, 4);
        const edge = this.edges[index];
        if (this.flipped) {
            if (direction % 2 === 0) {
                return reverse(edge);
            } else {
                return reverse(this.edges[posMod(index + 2, 4)]);
            }
        }
        return edge;
    }

    top = () => this.getEdge(Direction.Up);
    down = () => this.getEdge(Direction.Down);
    right = () => this.getEdge(Direction.Right);
    left = () => this.getEdge(Direction.Left);

    rotateCW() { if (this.flipped) { this.rotation--; } else { this.rotation++; } }
    rotateCCW() { if (this.flipped) { this.rotation++; } else { this.rotation--; } }
    flip() { this.flipped = !this.flipped; }

    print() {
        const [t, r, d, l] = [this.top(), this.right(), this.down(), this.left()];
        const width = t.length;

        console.log(t);
        for (let y = 1; y < width - 1; y++) {
            console.log([l[width - 1 - y], ...repeat(" ", width - 2), r[y]].join(""));
        }
        console.log(reverse(d));
    }

    findMatch(direction: Direction, tiles: Set<Tile>) {
        const edge = reverse(this.getEdge(direction));
        for (const tile of tiles) {
            tile.rotation = 0;
            tile.flipped = false;
            for (let i = 0; i < 4; i++) {
                if (tile.getEdge((direction + 2) % 4) === edge) {
                    return tile;
                }
                tile.rotateCW();
            }
            tile.flip();
            for (let i = 0; i < 4; i++) {
                if (tile.getEdge((direction + 2) % 4) === edge) {
                    return tile;
                }
                tile.rotateCW();
            }
        }
        return undefined;
    }

    symbolAt(x: number, y: number) {
        x += 1;
        y += 1;
        for (let i = 0; i < posMod(this.rotation, 4); i++) {
            [x, y] = this.flipped ? [9 - y, x] : [y, 9 - x];
        }

        if (this.flipped) {
            x = 9 - x;
        }

        return this.text[y][x];
    }
}

const tiles = input.split("\n\n").map(ts => Tile.fromInput(ts.split("\n")));
const tileSet = new Set(tiles);

// FInd corners
const corners = [];
for (const tile of tiles) {
     tileSet.delete(tile);
     if (range(0, 3).map(d => tile.findMatch(d, tileSet)).filter(m => m !== undefined).length == 2) {
         corners.push(tile);
     }
     tileSet.add(tile);
}

console.log("Part 1", product(corners.map(c => parseInt(c.id))));

// Rotate first corner so it has connections up and right
const corner = corners[0];
tileSet.delete(corner);

while (corner.findMatch(Direction.Down, tileSet) === undefined) {
    corner.rotateCW();
}
if (corner.findMatch(Direction.Right, tileSet) === undefined) {
    corner.flip();
    while (corner.findMatch(Direction.Down, tileSet) === undefined) {
        corner.rotateCW();
    }
}

// Find positions of all tiles
const queue = [corner];
while (queue.length > 0) {
    const t = queue.pop()!;

    const down = t.findMatch(Direction.Down, tileSet);
    if (down !== undefined) {
        down.position = [t.position[0], t.position[1] + 1];
        queue.push(down);
        tileSet.delete(down);
    }

    const right = t.findMatch(Direction.Right, tileSet);
    if (right !== undefined) {
        right.position = [t.position[0] + 1, t.position[1]];
        queue.push(right);
        tileSet.delete(right);
    }
}

const grid: Tile[][] = [];
const dimensions = Math.sqrt(tiles.length);

for (const tile of tiles) {
    if (grid[tile.position[1]] === undefined) {
        grid[tile.position[1]] = [];
    }
    grid[tile.position[1]][tile.position[0]] = tile;
}

function symbolAt(x: number, y: number) {
    const tileX = Math.floor(x / 8);
    const tileY = Math.floor(y / 8);

    const tile = grid[tileY][tileX];
    return tile.symbolAt(x % 8, y % 8);
}

const pattern = [
    "                  # ",
    "#    ##    ##    ###",
    " #  #  #  #  #  #   "
];

const patternWidth = pattern[0].length;
const patternHeight = pattern.length;

const imageDimension = dimensions *  8;

function findPattern(x: number, y: number, rotation: number, flipped: boolean): string[] | undefined {
    let coords = [];
    for (let px = 0; px < patternWidth; px++) {
        for (let py = 0; py < patternHeight; py++) {

            let [nx, ny] = [x + px, y + py];
            for (let r = 0; r < rotation; r++) {
                [nx, ny] = [(dimensions*8)-1-ny, nx];
            }
            if (flipped) {
                nx = dimensions * 8 - 1 - nx;
            }
            
            if (pattern[py][px] === "#" && symbolAt(nx, ny) !== "#") {
                return undefined;
            } else if (pattern[py][px] === "#") {
                coords.push(`${nx},${ny}`);
            }
        }
    }
    return coords;
}

function numPatterns(rotation: number, flipped: boolean) {
    let patterns = 0;
    const patternCoords = new Set<string>();
    for (let x = 0; x < imageDimension - patternWidth; x++) {
        for (let y = 0; y < imageDimension - patternHeight; y++) {
            const pattern = findPattern(x, y, rotation, flipped);
            if (pattern !== undefined) {
                pattern.forEach(p => patternCoords.add(p));
                patterns++;
            }        
        }
    }

    if (patterns > 0) {
        let roughness = 0;
        for (let x = 0; x < imageDimension; x++) {
            for (let y = 0; y < imageDimension; y++) {
                if (symbolAt(x, y) === "#") {
                    if (!patternCoords.has(`${x},${y}`)) {
                        roughness++;
                    }
                }   
            }
        }
        console.log("Part 2", roughness);
    }

    return patterns;
}

// Just try all rotations
numPatterns(0, false);
numPatterns(1, false);
numPatterns(2, false);
numPatterns(3, false);
numPatterns(0, true);
numPatterns(1, true);
numPatterns(2, true);
numPatterns(3, true);
