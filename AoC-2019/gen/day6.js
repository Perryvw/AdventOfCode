"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const edgeList = common_1.parseData("data/day6.data", l => l.split(")"));
const nodes = common_1.unique(edgeList.map(e => e[0]).concat(edgeList.map(e => e[1])));
const ancestors = common_1.memoize(ancestors_base);
function ancestors_base(node) {
    const backEdge = edgeList.find(e => e[1] === node);
    return backEdge
        ? [...ancestors(backEdge[0]), node]
        : [node];
}
// Part 1
console.log(`Part 1: ${common_1.sum(nodes.map(ancestors).map(as => as.length - 1))}`);
// Part 2
const youAncestors = ancestors("YOU");
const santaAncestors = ancestors("SAN");
const matchingCount = common_1.zip(youAncestors, santaAncestors).findIndex(v => v[0] !== v[1]);
console.log(`Part 2: ${youAncestors.length + santaAncestors.length - 2 * matchingCount - 2}`);
// Part 2 - bonus BFS
const connectedTo = common_1.memoize((node) => edgeList.filter(e => e[0] === node).map(e => e[1])
    .concat(edgeList.filter(e => e[1] === node).map(e => e[0])));
function BFS(from, to) {
    const newPaths = from.flatMap(path => connectedTo(path[0])
        .filter(c => c !== path[1])
        .map(c => [c, ...path]));
    const completePath = newPaths.find(p => p[0] === to);
    return completePath
        ? completePath
        : BFS(newPaths, to);
}
const path = BFS([["YOU"]], "SAN");
console.log(`Part 2 bonus BFS: ${path.length - 3}`);
