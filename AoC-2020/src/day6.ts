import { head, intersect, readData, sum, tail, union } from "./common";

const groups = readData("data/day6.data").split("\n\n")
    .map(group => group.split("\n").map(a => new Set(a.split(""))));

// Part 1
const differentAnswers = groups.map(answers => tail(answers).reduce((s, g) => union(s, g), head(answers)));
console.log("Part 1:", sum(differentAnswers.map(s => s.size)));

// Part 2
const sameAnswers = groups.map(answers => tail(answers).reduce((s, g) => intersect(s, g), head(answers)));
console.log("Part 2:", sum(sameAnswers.map(s => s.size)));