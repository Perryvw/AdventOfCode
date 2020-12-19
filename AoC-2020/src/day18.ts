import { parseData, sum } from "./common";

class Stream {
    length: number;
    position: number = 0;

    constructor(public buffer: string) {
        this.length = buffer.length
        this.buffer = this.buffer.replace(/\s/g, "");
    }

    public endOfStream(): boolean {
        return this.position >= this.length;
    }

    public nextCharacter(): string {
        const char = this.buffer[this.position];
        this.position++;
        return char;
    }

    public peekCharacter(): string {
        return this.buffer[this.position];
    }

    public reset() {
        this.position = 0;
    }
}

const formulas = parseData<Stream>("data/day18.data", l => new Stream(l));

function math(formula: Stream, nextValue: (f: Stream) => number): number {
    let value = nextValue(formula);
    
    while (!formula.endOfStream()) {
        const nextChar = formula.nextCharacter();
        if (nextChar === "+") {
            value += nextValue(formula);
        }
        else if (nextChar === "*") {
            value *= nextValue(formula);
        } else if (nextChar === ")") {
            return value;
        }
    }
    return value;
}

// Part 1
function nextValue1(formula: Stream): number {
    const nextChar = formula.nextCharacter();
    if (nextChar === "(") {
        return math(formula, nextValue1);
    }
    else {
        return parseInt(nextChar);
    } 
}

// Part 2
function nextValue2(formula: Stream): number {
    const nextChar = formula.nextCharacter();

    let value = nextChar === "("
        ? math(formula, nextValue2)
        : parseInt(nextChar);

    while (formula.peekCharacter() === "+") {
        formula.nextCharacter();
        value += nextValue2(formula);
    }

    return value;
}

console.log("Part 1:", sum(formulas.map(f => math(f, nextValue1))));
formulas.forEach(f => f.reset());
console.log("Part 2:", sum(formulas.map(f => math(f, nextValue2))));