import { parseData, sum } from "./common";

const masses = parseData("data/day1.data", l => parseInt(l));

// Part 1
const fuelRequired = (mass: number) => Math.floor(mass / 3) - 2;
const totalFuelCount = sum(masses.map(fuelRequired));

console.log(`Part 1: ${totalFuelCount}`);

// Part 2
function fuelRequiredRecursive(mass: number): number {
    const fuel = fuelRequired(mass);
    return fuel > 0
        ? fuel + fuelRequiredRecursive(fuel)
        : 0;
}

const totalFuelCountRecursive = sum(masses.map(fuelRequiredRecursive));
console.log(`Part 2: ${totalFuelCountRecursive}`);
