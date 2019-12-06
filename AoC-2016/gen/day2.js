"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const lines = common_1.readLines("data/day2.data");
// Part 1
function move(from, command) {
    const inc = command == "U" ? -3
        : command == "D" ? +3
            : command == "L" ? -1
                : 1;
    const newValue = from + inc;
    return newValue > 0 && newValue < 10
        ? newValue
        : from;
}
function getSequence(pos, commands) {
    const command = commands.shift();
    if (command) {
        const newPos = command.split("").reduce(move, pos);
        return [newPos, ...getSequence(newPos, commands)];
    }
    else {
        return [];
    }
}
const sequence = getSequence(5, lines).join("");
console.log(`Part 1: ${sequence}`);
// Part 2
//console.log(`Part 2: ${distance2}`);
