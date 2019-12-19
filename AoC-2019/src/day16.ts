import { parseDataLine, range, sum, repeatArray } from "./common";
import { sign } from "crypto";

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
/*function fftStepOptimized(signal: number[]): number[] {
    const result = [];
    for (let p = 0; p < signal.length; p++) {
        let v = 0;
        for (let x = 0; x < signal.length; x += (p + 1) * 4) {
            for (let y = p + x; y < 2 * p + 1 + x && y < signal.length; y++) {
                v += signal[y];
            }
            for (let y = p + x + (p + 1) * 2; y < (p + 1) * 2 + 2 * p + 1 + x && y < signal.length; y++) {
                v -= signal[y];
            }
        }
        result[p] = Math.abs(v) % 10;
    }
    
    return result;
}

const fftOptimized = (signal: number[], numPhases: number) =>
    range(1, numPhases).reduce((pSignal, v) => { console.log(v); return fftStepOptimized(pSignal); }, signal);*/

const posNumberRanges = (signal: number[], depth: number) =>
    range(0, Math.max(1, Math.floor(signal.length / ((depth + 1) * 4))) - 1)
            .map(i => [depth + i * 4, i * 4 + 2 * depth]);

const negNumberRanges = (signal: number[], depth: number) =>
range(0, Math.max(1, Math.floor(signal.length / ((depth + 1) * 4))) - 1)
        .map(i => [depth + i * 4 + (depth + 1) * 2, 2 * depth + i * 4 + (depth + 1) * 2]);

function fftStepOptimized(signal: number[]): number[] {
    const result = [];
    let prevVal = 0;
    for (let p = 0; p < signal.length; p++) {
        posNumberRanges(signal, p).forEach(([from, to]) => {
            if (from - 1 > 0 && from <= signal.length) prevVal -= signal[from - 1];
            if (to - 1 < signal.length && to > 0) prevVal += signal[to - 1];
            if (to < signal.length) prevVal += signal[to];
        });
        posNumberRanges(signal, p).forEach(([from, to]) => {
            if (from - 1 > 0 && from <= signal.length) prevVal -= signal[from - 1];
            if (to - 1 < signal.length && to > 0) prevVal += signal[to - 1];
            if (to < signal.length) prevVal += signal[to];
        });
        console.log(prevVal)
        result[p] = prevVal;
        //console.log(negNumberRanges(signal, p));
        //console.log(edgeNumbersToAdd(signal, p));
        /*range(1, Math.max(1, Math.floor(signal.length / ((p + 1) * 4)))).forEach(i => {
            console.log(p + 4 * (i - 1));
        });*/
    }
    return result;
}

console.log(`Part 2: ${fftStepOptimized(signal).slice(0, 8).join("")}`);
//console.log(`Part 2: ${fftOptimized(repeatArray(signal, 2), 4).slice(0, 8).join("")}`);
//console.log(`Part 2: ${fftOptimized(repeatArray(signal, 3), 4).slice(0, 8).join("")}`);
