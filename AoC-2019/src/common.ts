import * as fs from "fs";
import { performance } from "perf_hooks";

export function readLines(filePath: string): string[] {
    const file = fs.readFileSync(filePath);
    const fileString = new String(file);
    return fileString.split("\n").map(s => s.trim());
}

export function parseData<T>(filePath: string, parser: (line: string) => T): T[] {
   return readLines(filePath).map(parser);
}

export function parseDataLine<T>(filePath: string, parser: (line: string) => T, delimiter = ","): T[] {
    const line = readLines(filePath)[0];
    return line.split(delimiter).map(v => parser(v.trim()));
}

export function sum(values: number[]): number {
    return values.reduce((a, b) => a + b, 0);
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

export function measureTime<T>(name: string, action: () => T): T {
    const start = performance.now();
    const result = action();
    const duration = performance.now() - start;
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
