"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const fs = require("fs");
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
function sum(values) {
    return values.reduce((a, b) => a + b, 0);
}
exports.sum = sum;
