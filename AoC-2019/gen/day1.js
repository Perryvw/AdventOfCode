"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("./common");
const masses = common_1.parseData("data/day1.data", l => parseInt(l));
// Part 1
const fuelRequired = (mass) => Math.floor(mass / 3) - 2;
const totalFuelCount = common_1.sum(masses.map(fuelRequired));
console.log(`Part 1: ${totalFuelCount}`);
// Part 2
function fuelRequiredRecursive(mass) {
    const fuel = fuelRequired(mass);
    return fuel > 0
        ? fuel + fuelRequiredRecursive(fuel)
        : 0;
}
const totalFuelCountRecursive = common_1.sum(masses.map(fuelRequiredRecursive));
console.log(`Part 2: ${totalFuelCountRecursive}`);
