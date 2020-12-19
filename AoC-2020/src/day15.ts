import { last } from "./common";

const input = [19,20,14,0,9,1];

const map = new Map<number, number>();
let lastNr = last(input);

for (let i = 0; i < input.length - 1; i++) {
    map.set(input[i], i);
}

for (let i = input.length; i < 30000000; i++) {
    if (i === 2020) console.log("Part 1", lastNr);

    const lastIndex = map.get(lastNr);

    map.set(lastNr, i - 1);
    lastNr = lastIndex !== undefined ? i - 1 - lastIndex : 0;
}

console.log("Part 2", lastNr);