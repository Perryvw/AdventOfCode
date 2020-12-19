import { lcm, minItem, parseData, posMod } from "./common";

const data = parseData("data/day13.data", l => l);

const timestamp = parseInt(data[0]);
const busses = data[1].split(",");

// Part 1
const ids = busses.filter(b => b !== "x").map(b => parseInt(b));

const departures = ids.map(id => ({ bus: id, departure: id - (timestamp % id) }));
const nextBus = minItem(departures, b => b.departure);

console.log("Part 1", nextBus.departure * nextBus.bus);

// Part 2
const expectedDepartures = busses.map((id, i) => ({ id: parseInt(id), sequence: i }))
    .filter(b => !isNaN(b.id));

let t = 0;
let increment = 1;
const found = [1];

for (const bus of expectedDepartures) {
    while (t % bus.id !== posMod(bus.id - bus.sequence, bus.id)) {
        t += increment;
    }
    found.push(bus.id);
    increment = lcm(...found);
}

console.log("Part 2:", t);
