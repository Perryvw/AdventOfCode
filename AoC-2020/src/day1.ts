import { contains, head, parseData, product, tail } from "./common";

const nums = parseData("data/day1.data", (l) => parseInt(l));

// Part 1
function findSumPair(arr: number[], sum: number): [number, number] | undefined {
    if (arr.length === 0) return undefined;

    const h = head(arr);
    const t = tail(arr);

    return contains(t, sum - h)
        ? [h, sum - h]
        : findSumPair(t, sum);
}

console.log("Part 1: ", findSumPair(nums, 2020), product(findSumPair(nums, 2020)!));

// Part 2
function find2020Triplet(arr: number[]): [number, number, number] | undefined {
    if (arr.length === 0) return undefined;

    const h = head(arr);
    const t = tail(arr);
    const pair = findSumPair(t, 2020 - h);

    return pair !== undefined
        ? [h, ...pair]
        : find2020Triplet(t);
}

console.log("Part 2: ", find2020Triplet(nums), product(find2020Triplet(nums)!));
