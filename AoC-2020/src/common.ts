import * as fs from "fs";
import { performance } from "perf_hooks";

export function readData(filePath: string): string {
    const file = fs.readFileSync(filePath);
    return new String(file) as string;
}

export function readLines(filePath: string, trim = true): string[] {
    const fileString = readData(filePath);
    return trim
        ? fileString.split("\n").map(s => s.trim())
        : fileString.split("\n");
}

export function parseData<T>(filePath: string, parser: (line: string) => T, trim = true): T[] {
   return readLines(filePath, trim).map(parser);
}

export function parseDataLine<T>(filePath: string, parser: (line: string) => T, delimiter = ","): T[] {
    const line = readLines(filePath)[0];
    return line.split(delimiter).map(v => parser(v.trim()));
}

export function sum(values: number[]): number {
    return values.reduce((a, b) => a + b, 0);
}

export function product(values: number[]): number {
    return values.reduce((a, b) => a * b, 1);
}

export function max(values: number[]): number {
    return values.reduce((a, b) => Math.max(a, b));
}

export function maxItem<T>(items: T[], selector: (item: T) => number): T {
    const itemValues = items.map(i => [i, selector(i)] as const);
    return itemValues.reduce((a, b) => a[1] < b[1] ? b : a)[0];
}

export function min(values: number[]): number {
    return values.reduce((a, b) => Math.min(a, b));
}

export function minItem<T>(items: T[], selector: (item: T) => number): T {
    const itemValues = items.map(i => [i, selector(i)] as const);
    return itemValues.reduce((a, b) => a[1] < b[1] ? a : b)[0];
}

export function updateArray<T>(array: T[], index: number, newValue: T): T[] {
    return splice(array, index, 1, newValue);
}

export function splice<T>(array: T[], start: number, deleteCount: number, ...items: T[]): T[] {
    const copy = [...array];
    copy.splice(start, deleteCount, ...items);
    return copy;
}

export function range(start: number, end: number): number[] {
    const length = Math.abs(end - start) + 1;
    const fac = start <= end ? 1 : -1;
    return new Array(length).fill(0).map((_, i) => start + i * fac);
}

export function combinations<TLeft, TRight>(left: TLeft[], right: TRight[]): Array<[TLeft, TRight]> {
    return left.flatMap(x => right.map(y => [x, y] as [TLeft, TRight]));
}

export function isBetween(value: number, min: number, max: number) {
    return value >= min && value <= max;
}

export function enumerate<T>(array: T[]): Array<[number, T]> {
    return array.map((v, i) => [i, v]);
}

export function measureTime<T>(name: string, action: () => T, repetitions = 1): T {
    const start = performance.now();
    const result = action();
    for (let i = 0; i < repetitions - 1; i++) {
        action();
    }
    const duration = (performance.now() - start) / repetitions;
    console.log(`Timed '${name}': ${duration}ms`);
    return result;
}

export function unique<T>(array: T[]): T[] {
    return [...new Set(array)];
}

export function memoize<TArg extends string | number, TResult>(func: (arg: TArg) => TResult): (arg: TArg) => TResult {
    const memory = {} as Record<TArg, TResult>;
    return (arg: TArg) => {
        if (memory[arg]) {
            return memory[arg];
        } else {
            return memory[arg] = func(arg);
        }
    }
}

export function zip<TLeft, TRight>(left: TLeft[], right: TRight[]): Array<[TLeft, TRight]> {
    return left.length > right.length
        ? right.map((r, i) => [left[i], r])
        : left.map((l, i) => [l, right[i]]);
}

export function permutations<T>(items: T[]): Array<T[]> {
    return items.length === 1
        ? [items]
        : items.flatMap((item, index) =>
            permutations(splice(items, index, 1)).map(p => [item, ...p]));
}

export function last<T>(items: T[]): T {
    return items[items.length - 1];
}

export function resize<T>(array: T[], length: number, defaultValue: T): T[] {
    return array.length >= length
        ? array.slice(0, length)
        : [...array, ...range(0, length - array.length).map(() => defaultValue)];
}

export function orderBy<T>(items: T[], selector: (arg: T) => number, secondarySelector: (arg: T) => number = () => 0): T[] {
    const itemValues = items.map(i => [i, selector(i), secondarySelector(i)] as const);
    return itemValues.sort((i1, i2) => i1[1] - i2[1] === 0 ? i1[2] - i2[2] : i1[1] - i2[1]).map(i => i[0]);
}

export function gcd(...items: number[]): number {
    return items.length === 2
        ? items[1] === 0 ? items[0] : gcd(items[1], items[0] % items[1])
        : gcd(items[0], gcd(...items.slice(1)));
}

export function lcm(...items: number[]): number {
    return items.length === 2
        ? Math.abs(items[0] * items[1]) / gcd(items[0], items[1])
        : lcm(items[0], lcm(...items.slice(1)));
}

export function binaryMinimize(lower: number, upper: number, validateOption: (v: number) => boolean): number {
    const half = Math.floor((lower + upper) / 2);
    const isValid = validateOption(half);
    return lower >= upper
        ? (isValid ? lower : half + 1)
        : isValid
            ? binaryMinimize(lower, half - 1, validateOption)
            : binaryMinimize(half + 1, upper, validateOption);
}

export function binaryMaximize(lower: number, upper: number, validateOption: (v: number) => boolean): number {
    const half = Math.floor((lower + upper) / 2);
    const isValid = validateOption(half);
    return lower >= upper
        ? (isValid ? upper : half - 1)
        : isValid
            ? binaryMaximize(half + 1, upper, validateOption)
            : binaryMaximize(lower, half - 1, validateOption);
}

export function repeat<T>(value: T, count: number): T[] {
    return new Array(count).fill(value);
}

export function repeatArray<T>(array: T[], count: number): T[] {
    return range(1, count).flatMap(() => array);
}

export function countTrue(...args: boolean[]): number {
    return args.filter(a => a).length;
}

export function log<T>(value: T, ...additionalValues: any[]): T {
    console.log(value, ...additionalValues);
    return value;
}

export function uniqueOn<T>(values: T[], selector: (v: T) => string) {
    return [...new Map(values.map(v => [selector(v), v])).values()];
}

export function join<TLeft, TRight, TResult>(
    left: TLeft[],
    right: TRight[],
    condition: (left: TLeft, right: TRight) => boolean,
    result: (left: TLeft, right: TRight) => TResult): TResult[]
{
    return left.flatMap(l => right.filter(r => condition(l, r)).map(r => result(l, r)));
}

export function surroundingCoords(x: number, y: number): Array<[number, number]> {
    return [[x + 1, y], [x - 1, y], [x, y + 1], [x, y - 1]];
}

type BfsGoalPredicate<TState> = (state: TState) => boolean;
type BfsTransitionFunction<TState> = (currentStates: TState) => TState[];
type BfsHashFunction<TState> = (state: TState) => string | number;
export function bfs<TState>(
    initialState: TState[],
    goalReached: BfsGoalPredicate<TState>,
    nextStates: BfsTransitionFunction<TState>,
    hashFunction: BfsHashFunction<TState>
): TState[] | undefined {
    const seen = new Set<string | number>();
    let queue = initialState.map(s => [s]);
    while (queue.length > 0) {
        const path = queue.shift()!;
        const state = last(path);
        if (goalReached(state)) {
            return path;
        }
        const hash = hashFunction(state);
        if (seen.has(hash)) {
            continue;
        }
        seen.add(hash);
        queue.push(...nextStates(state).map(newState => [...path, newState]));
    }
}

export function toLookUp<TKey extends string | number, TValue>(list: TValue[], keySelector: (value: TValue) => TKey): Record<TKey, TValue[]> {
    const map = {} as Record<TKey, TValue[]>;
    for (const v of list) {
        const key = keySelector(v);
        if (!map[key]) {
            map[key] = [];
        }
        map[key].push(v);
    }
    return map;
}

export function partitionBySize<T>(list: T[], size: number): Array<T[]> {
    return range(0, Math.ceil(list.length / size) - 1).map(n => list.slice(n * size, n * size + size));
}

export function allSubsets<T>(items: T[]): Array<T[]> {
    return items.length === 1
        ? [items, []]
        : allSubsets(items.slice(1)).flatMap(c => [[items[0], ...c], c]);
}

export function head<T>(arr: T[]): T {
    return arr[0];
}

export function tail<T>(arr: T[]): T[] {
    return arr.slice(1);
}

export function contains<T>(arr: T[], value: T): boolean {
    return arr.length === 0 ? false
        : head(arr) === value ? true
        : contains(tail(arr), value);
}

export function xor(a: boolean, b: boolean): boolean {
    return (a || b) && !(a && b);
}

export function union<T>(s1: Set<T>, s2: Set<T>): Set<T> {
    return new Set([...s1, ...s2]);
}

export function intersect<T>(s1: Set<T>, s2: Set<T>): Set<T> {
    return new Set([...s1].filter(x => s2.has(x)));
}

export function except<T>(s1: Set<T>, s2: Set<T>): Set<T> {
    return new Set([...s1].filter(x => !s2.has(x)));
}

export function countItems<T extends string | number>(arr: T[]): Record<T, number> {
    return arr.reduce((dict, item) => {
        if (item in dict) {
            dict[item]++;
        } else {
            dict[item] = 1;
        }
        return dict;
    },
    {} as Record<T, number>);
}

export function posMod(value: number, modulo: number) : number {
    const mod = value % modulo;
    return mod >= 0 ? mod : mod + modulo;
}

export function transpose(matrix: number[][]): number[][] {
    const result: number[][] = [];
    for (let i = 0; i < matrix[0].length; i++) {
        result[i] = [];
        for (let j = 0; j < matrix.length; j++) {
            result[i][j] = matrix[j][i];
        }
    }
    return result;
}
