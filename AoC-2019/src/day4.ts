import { range, measureTime } from "./common";

const lower = 307237;
const upper = 769058;

// Part 1
const getDigitAt = (value: number, index: number) => Math.floor(value / Math.pow(10,  index)) % 10;
const getTwoDigitsAt = (value: number, index: number) => Math.floor(value / Math.pow(10, index)) % 100;
const hasSameAdjacentDigits = (value: number) => getTwoDigitsAt(value, 0) % 11 === 0
    || getTwoDigitsAt(value, 1) % 11 === 0
    || getTwoDigitsAt(value, 2) % 11 === 0
    || getTwoDigitsAt(value, 3) % 11 === 0
    || getTwoDigitsAt(value, 4) % 11 === 0
    || getTwoDigitsAt(value, 5) % 11 === 0;

function generateAscendingNumbersOfLength(length: number, maxValue: number = 9): number[] {
    const numRange = range(0, maxValue);
    return length === 1 
        ? numRange
        : numRange.flatMap(n => generateAscendingNumbersOfLength(length - 1, n).map(v => v * 10 + n));
}

const passwords = generateAscendingNumbersOfLength(6)
    .filter(n => n >= lower && n <= upper)
    .filter(hasSameAdjacentDigits);

console.log(`Part 1: ${passwords.length}`);

// Part 2
const c2 = (value: number) => (getTwoDigitsAt(value, 0) % 11 === 0 && getDigitAt(value, 2) !== getDigitAt(value, 0))
    || (getTwoDigitsAt(value, 1) % 11 === 0 && getDigitAt(value, 1) !== getDigitAt(value, 0) && getDigitAt(value, 1) !== getDigitAt(value, 3))
    || (getTwoDigitsAt(value, 2) % 11 === 0 && getDigitAt(value, 2) !== getDigitAt(value, 1) && getDigitAt(value, 2) !== getDigitAt(value, 4))
    || (getTwoDigitsAt(value, 3) % 11 === 0 && getDigitAt(value, 3) !== getDigitAt(value, 2) && getDigitAt(value, 3) !== getDigitAt(value, 5))
    || (getTwoDigitsAt(value, 4) % 11 === 0 && getDigitAt(value, 4) !== getDigitAt(value, 3));

const p2Passwords = passwords.filter(c2);
console.log(`Part 2: ${p2Passwords.length}`);
