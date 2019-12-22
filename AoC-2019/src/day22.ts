import { range, parseData, gcd, lcm } from "./common";

const dealIntoStack = (cards: number[]) => cards.reverse();

const cutNCards = (cards: number[], cut: number) => cut > 0 
    ? [...cards.slice(cut), ...cards.slice(0, cut)]
    : [...cards.slice(cards.length + cut), ...cards.slice(0, cards.length + cut)];

function dealWithIncrementN(cards: number[], increment: number): number[] {
    let pos = 0;
    const result = new Array(cards.length).fill(0);
    for (const card of cards) {
        result[pos] = card;
        pos = (pos + increment) % cards.length;
    }
    return result;
}

const algorithm = parseData("data/day22.data", l => l.split(" "));
function shuffle(deck: number[]): number[] {
    for (const step of algorithm) {
        deck = step[0] === "cut" ? cutNCards(deck, parseInt(step[1]))
            : step[1] === "into" ? dealIntoStack(deck)
            : dealWithIncrementN(deck, parseInt(step[3]));
    }
    return deck;
}

// Part 1
console.log(`Part 1: ${shuffle(range(0, 10006)).indexOf(2019)}`);

// Part 2
const modExp = function(x: bigint, y: bigint, p: bigint) {
    let res = 1n;      // Initialize result 
  
    x = x % p;  // Update x if it is more than or  
                // equal to p 
  
    while (y > 0) 
    { 
        // If y is odd, multiply x with result 
        if (y & 1n) 
            res = (res*x) % p; 
  
        // y must be even now 
        y = y>>1n; // y = y/2 
        x = (x*x) % p;   
    } 
    return res; 
  };

const numCards = 119_315_717_514_047n;
const numShuffles = 101_741_582_076_661n;

function toLinearEquation(): [bigint, bigint] {
    let mult = 1n;
    let offset = 0n;

    for (const step of algorithm.reverse()) {
        if (step[0] === "cut") {
            offset += BigInt(parseInt(step[1])) + numCards;
        } else if (step[1] === "into") {
            offset = numCards - BigInt(1) - offset;
        } else {
            const n = modExp(BigInt(parseInt(step[3])), numCards - 2n, numCards);
            mult *= n;
            offset *= n;
        }
        mult %= numCards;
        offset %= numCards;
    }
    return [mult, offset];
}

// Shuffling mult * card + offset
const [mult, offset] = toLinearEquation();

// Shuffling cardAtPos(x) = mult * x + offset

// Applying cardAtPos n times yields formula: (geometric series)
// mult^n * x + offset * (mult^n - 1) * modInverse(mult - 1);

// mult^n * x
const left = modExp(mult, numShuffles, numCards) * 2020n % numCards;
// offset * (mult^n - 1) * modInverse(mult - 1)
const right = offset * (modExp(mult, numShuffles, numCards) - 1n) * modExp(mult - 1n, numCards - 2n, numCards) % numCards;
//const right = offset * (modExp(mult, numShuffles, numCards) - 1n) * modExp(mult - 1n, numCards - 2n, numCards) % numCards;

console.log(`Part 2: ${left + right}`);

