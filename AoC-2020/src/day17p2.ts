import { parseData } from "./common"

const inp = parseData("data/day17.data", l => l.split(""));
const inpWidth = inp[0].length;
const inpLength = inp.length;

function* surroundingCoords(cx: number, cy: number, cz: number, cw: number) {
    for (let x = cx - 1; x <= cx + 1; x++)
    for (let y = cy - 1; y <= cy + 1; y++)
    for (let z = cz - 1; z <= cz + 1; z++)
    for (let w = cw - 1; w <= cw + 1; w++) {
        if (x !== cx || y !== cy || z !== cz || w !== cw)
        yield [x, y, z, w];
    }
}

let state = new Set<number>();

//const coordHash = (x: number, y: number, z: number, w: number) => `${x},${y},${z},${w}`;
const coordHash = (x: number, y: number, z: number, w: number) => x + y * 100 + z * 10000 + w * 1000000;

for (let y = 0; y < inp.length; y++) {
    for (let x = 0; x < inp[0].length; x++) {
        if (inp[y][x] === "#") {
            state.add(coordHash(x, y, 0, 0));
        }
    }
}

for (let i = 0; i < 6; i++) {
    const newState = new Set<number>();

    const minzw = -i - 1;
    const maxzw = i + 1;
    const minx = -i - 1;
    const maxx = inpWidth + i + 1;
    const miny = -i - 1;
    const maxy = inpLength + i + 1;

    for (let x = minx; x <= maxx; x++) {
        for (let y = miny; y <= maxy; y++) {
            for (let z = minzw; z <= maxzw; z++) {
                for (let w = minzw; w <= maxzw; w++) {
                    const coord = coordHash(x, y, z, w);
                    const isActive = state.has(coord);

                    const surroundingActive = [...surroundingCoords(x, y, z, w)]
                        .filter(([x, y, z, w]) => state.has(coordHash(x, y, z, w)))
                        .length;

                    if (isActive && (surroundingActive === 2 || surroundingActive === 3)) {
                        newState.add(coord);
                    } else if (surroundingActive === 3) {
                        newState.add(coord);
                    }
                }
            }
        }
    }

    state = newState;
}

console.log(state.size);
//console.log(state);