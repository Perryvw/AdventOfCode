import { parseData } from "./common"

const inp = parseData("data/day17.data", l => l.split(""));
const inpWidth = inp[0].length;
const inpLength = inp.length;

const surroundingCoords = (x: number, y: number, z: number) => [
    [x, y, z-1],[x+1, y, z-1],[x+1, y+1, z-1],[x+1, y-1, z-1],[x-1, y, z-1],[x-1, y+1, z-1],[x-1, y-1, z-1],[x, y+1, z-1],[x, y-1, z-1],
    [x+1, y, z],[x+1, y+1, z],[x+1, y-1, z],[x-1, y, z],[x-1, y+1, z],[x-1, y-1, z],[x, y+1, z],[x, y-1, z],
    [x, y, z+1],[x+1, y, z+1],[x+1, y+1, z+1],[x+1, y-1, z+1],[x-1, y, z+1],[x-1, y+1, z+1],[x-1, y-1, z+1],[x, y+1, z+1],[x, y-1, z+1],
];

let state = new Set<string>();

const coordHash = (x: number, y: number, z: number) => `${x},${y},${z}`;

for (let y = 0; y < inp.length; y++) {
    for (let x = 0; x < inp[0].length; x++) {
        if (inp[y][x] === "#") {
            state.add(coordHash(x, y, 0));
        }
    }
}

for (let i = 0; i < 6; i++) {
    const newState = new Set<string>();

    const minz = -i - 1;
    const maxZ = i + 1;
    const minx = -i - 1;
    const maxx = inpWidth + i + 1;
    const miny = -i - 1;
    const maxy = inpLength + i + 1;

    for (let x = minx; x <= maxx; x++) {
        for (let y = miny; y <= maxy; y++) {
            for (let z = minz; z <= maxZ; z++) {
                const coord = coordHash(x, y, z);
                const isActive = state.has(coord);

                const surroundingActive = surroundingCoords(x, y, z)
                    .filter(([x, y, z]) => state.has(coordHash(x, y, z)))
                    .length;

                if (isActive && (surroundingActive === 2 || surroundingActive === 3)) {
                    newState.add(coord);
                } else if (surroundingActive === 3) {
                    newState.add(coord);
                }
            }
        }
    }

    state = newState;
}

console.log(state.size);