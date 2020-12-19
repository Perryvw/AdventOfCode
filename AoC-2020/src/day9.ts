import { contains, head, max, min, parseData, tail } from "./common";

const input = parseData("data/day9.data", l => parseInt(l));

function findSumPair(arr: number[], sum: number): [number, number] | undefined {
    if (arr.length === 0) return undefined;

    const h = head(arr);
    const t = tail(arr);

    return contains(t, sum - h)
        ? [h, sum - h]
        : findSumPair(t, sum);
}

function findMismatch(nums: number[], preamble: number): number | undefined {
    const queue = nums.slice(0, preamble);
    
    for (let i = preamble; i < nums.length; i++) {
        if (findSumPair(queue, nums[i]) === undefined) {
            return nums[i];
        }
        queue.shift();
        queue.push(nums[i]);
    }

    return undefined;
}

const mismatch = findMismatch(input, 25);
console.log("Part 1", mismatch);

// Part 2
function findRange(nums: number[], value: number): [number, number] {
    let sum = 0;
    let lower = 0;
    let upper = 0;

    while (sum !== value) {
        if (sum < value) {
            upper++;
            sum += nums[upper];
        }
        if (sum > value) {
            lower++;
            sum -= nums[lower];
        }
    }

    return [lower + 1, upper - 1];
}

const range = findRange(input, mismatch!);
const answerVals = input.slice(range[0], range[1] + 1);
const minNum = min(answerVals);
const maxNum = max(answerVals);

console.log("Part 2:", "indexes:", range, "nrs", minNum, maxNum, "sum", minNum + maxNum);