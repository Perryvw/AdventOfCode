import { parseData, sum } from "./common";

const input = parseData("data/day14.data", l => l);

// Part 1
const memory = [];
let andMask = -1n;
let orMask = 0n;

function printBits(n: BigInt) {
    console.log((n).toString(2));
}

for (const line of input) {
    if (line.startsWith("mask =")) {
        andMask = -1n;
        orMask = 0n;

        for (let i = 0; i < line.length - 7; i++) {
            if (line[i + 7] === "0") {
                andMask &= ~(1n << BigInt(line.length - 8 -i));
            } else if (line[i + 7] === "1") {
                orMask |= 1n << BigInt(line.length - 8 - i);
            }
        }
    }
    else {
        const match = /mem\[(\d+)\] = (\d+)/.exec(line);
        const index = parseInt(match![1]);
        const value = BigInt(match![2]);

        memory[index] = (value & andMask) | orMask;
    }
}

console.log("Part 1:", Object.values(memory).reduce((s, a) => s + a, 0n));

function addresses2(mask: string, address: bigint): bigint[] {
    if (mask.length === 1) {
        return mask[0] === "X"? [1n, 0n]
            : mask[0] === "1" ? [1n] 
            : [address & 1n];
    }
    
    const children = addresses2(mask.slice(1), address);
    const head = mask[0];

    if (head === "1") {
        return children.map(c => c | (1n << BigInt(mask.length - 1)));
    } else if (head === "0") {
        return children.map(c => c | (BigInt(address) & (1n << BigInt(mask.length - 1))));
    } else {
        return [...children, ...children.map(c => c | (1n << BigInt(mask.length - 1)))];
    }
}

const memory2 = new Map<bigint, bigint>();
let mask = "";

for (const line of input) {
    if (line.startsWith("mask =")) {
        mask = line.slice(7);
    }
    else {
        const match = /mem\[(\d+)\] = (\d+)/.exec(line);
        const index = BigInt(match![1]);
        const value = BigInt(match![2]);

        for (const address of addresses2(mask, index)) {
            memory2.set(address, value);
        }
    }
}

console.log("Part 2:", [...memory2.values()].reduce((s, a) => s + a, 0n));