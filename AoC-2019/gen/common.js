"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
const perf_hooks_1 = require("perf_hooks");
function readLines(filePath) {
    const file = fs.readFileSync(filePath);
    const fileString = new String(file);
    return fileString.split("\n").map(s => s.trim());
}
exports.readLines = readLines;
function parseData(filePath, parser) {
    return readLines(filePath).map(parser);
}
exports.parseData = parseData;
function parseDataLine(filePath, parser, delimiter = ",") {
    const line = readLines(filePath)[0];
    return line.split(delimiter).map(v => parser(v.trim()));
}
exports.parseDataLine = parseDataLine;
function sum(values) {
    return values.reduce((a, b) => a + b, 0);
}
exports.sum = sum;
function updateArray(array, index, newValue) {
    return splice(array, index, 1, newValue);
}
exports.updateArray = updateArray;
function splice(array, start, deleteCount, ...items) {
    const copy = [...array];
    copy.splice(start, deleteCount, ...items);
    return copy;
}
exports.splice = splice;
function range(start, end) {
    const length = Math.abs(end - start) + 1;
    const fac = start <= end ? 1 : -1;
    return new Array(length).fill(0).map((_, i) => start + i * fac);
}
exports.range = range;
function combinations(left, right) {
    return left.flatMap(x => right.map(y => [x, y]));
}
exports.combinations = combinations;
function isBetween(value, min, max) {
    return value >= min && value <= max;
}
exports.isBetween = isBetween;
function enumerate(array) {
    return array.map((v, i) => [i, v]);
}
exports.enumerate = enumerate;
function measureTime(name, action) {
    const start = perf_hooks_1.performance.now();
    const result = action();
    const duration = perf_hooks_1.performance.now() - start;
    console.log(`Timed '${name}': ${duration}ms`);
    return result;
}
exports.measureTime = measureTime;
function unique(array) {
    return [...new Set(array)];
}
exports.unique = unique;
function memoize(func) {
    const memory = {};
    return (arg) => {
        if (memory[arg]) {
            return memory[arg];
        }
        else {
            return memory[arg] = func(arg);
        }
    };
}
exports.memoize = memoize;
function zip(left, right) {
    return left.length > right.length
        ? right.map((r, i) => [left[i], r])
        : left.map((l, i) => [l, right[i]]);
}
exports.zip = zip;
