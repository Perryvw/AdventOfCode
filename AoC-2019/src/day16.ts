import { parseDataLine, range, sum, repeatArray, last, log, lcm } from "./common";

const signal = parseDataLine("data/day16.data", parseInt, "");

// Part 1
const factor = (n: number, depth: number) => [0, 1, 0, -1][Math.floor((n + 1) / (depth + 1)) % 4];

const applyPattern = (signal: number[], depth: number) =>
    Math.abs(sum(signal.map((n, i) => n * factor(i, depth))) % 10);

const fftStep = (signal: number[]) =>
    signal.map((_, i) => applyPattern(signal, i));

const fft = (signal: number[], numPhases: number) =>
    range(1, numPhases).reduce((pSignal) => fftStep(pSignal), signal);


console.log(`Part 1: ${fft(signal, 100).slice(0, 8).join("")}`);

// Part 2
const offset = sum(signal.slice(0, 7).map((v, i) => v * Math.pow(10, 6 - i)));
const longsignal = repeatArray(signal, 10000);
const result = longsignal.slice(offset);
for (let l = 0; l < 100; l++) {
    let val = 0;
    for (let j = longsignal.length - 1; j >= offset; j--) {
        val += result[j - offset];
        result[j-offset] = val % 10;
    }
}
console.log(`Part 2: ${result.slice(0, 8).join("")}`);
