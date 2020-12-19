import { countItems, last, max, parseData, product } from "./common";

const adapters = parseData("data/day10.data", l => parseInt(l));

// Part 1
const deviceJoltage = max(adapters) + 3;

const sorted = adapters.sort((a, b) => a - b);

const diffs = sorted.map((adapter, i, list) => {
        return i === 0  ? adapter
            : adapter - list[i - 1];
    })
    .concat(deviceJoltage - last(sorted));

const counts = countItems(diffs);
console.log("Part 1:", counts, product(Object.values(counts)));

// Part 2
function oneSequences(ns: number[]): number[] {
    const sequences = [];
    for (let i = 0; i < ns.length; i++) {
        if (ns[i] === 1) {
            let l = 1;
            i++;
            for (;;i++) {
                if (ns[i] !== 1) {
                    sequences.push(l);
                    break;
                }
                l++;
            }
        }
    }
    return sequences
}

const tribonacci = (n: number): number => n < 2 ? 0
    : n === 2 ? 1
    : tribonacci(n - 1) + tribonacci(n - 2) + tribonacci(n - 3);

const result = product(oneSequences(diffs).map(v => tribonacci(v + 2)));
console.log("Part 2:", result);
