import * as fs from "fs";

export function readLines(filePath: string): string[] {
    const file = fs.readFileSync(filePath);
    const fileString = new String(file);
    return fileString.split("\n").map(s => s.trim());
}

export function parseData<T>(filePath: string, parser: (line: string) => T): T[] {
   return readLines(filePath).map(parser);
}

export function sum(values: number[]): number {
    return values.reduce((a, b) => a + b, 0);
}
