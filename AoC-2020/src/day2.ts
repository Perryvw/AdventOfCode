import { isBetween, parseData, xor } from "./common";

const dataRegex = /(\d+)-(\d+) (\w): (\w+)/;
const mapRegexResult = (r: RegExpExecArray) => {
    const [_, min, max, char, password] = r;
    return { min: parseInt(min), max: parseInt(max), char, password };
};
const input = parseData("data/day2.data", l => mapRegexResult(dataRegex.exec(l)!));

// Part 1
const occurrences = (str: string, ofValue: string) => str.split("").filter(c => c === ofValue).length;
const result = input.filter(inp => isBetween(occurrences(inp.password, inp.char), inp.min, inp.max)).length;

console.log("Part 1:", result);

// Part 2
const result2 = input.filter(inp => xor(inp.password[inp.min - 1] === inp.char, inp.password[inp.max - 1] === inp.char)).length;

console.log("Part 2:", result2);