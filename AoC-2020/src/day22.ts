import { measureTime, readData, sum } from "./common";

const [player1inp, player2inp] = readData("data/day22.data").split("\n\n")
                                    .map(ls => ls.split("\n").slice(1).map(n => parseInt(n)));

const p1Stack = [...player1inp];
const p2Stack = [...player2inp];

while (p1Stack.length > 0 && p2Stack.length > 0) {
    const p1Card = p1Stack.shift()!;
    const p2Card = p2Stack.shift()!;

    if (p1Card > p2Card) {
        p1Stack.push(p1Card, p2Card);
    } else {
        p2Stack.push(p2Card, p1Card);
    }
}

const winningDeck = p1Stack.length === 0 ? p2Stack : p1Stack;
console.log("Part 1:", sum(winningDeck.map((v, i) => v * (winningDeck.length - i))));

enum Winner { Player1, Player2 }

function play(deck1: number[], deck2: number[]): Winner {
    const seen = new Set<string>();
    
    while (deck1.length > 0 && deck2.length > 0) {

        const p1hash = `p1:${deck1}`;
        const p2hash = `p2:${deck2}`;
        if (seen.has(p1hash) || seen.has(p2hash)) {
            return Winner.Player1;
        }
        seen.add(p1hash);
        seen.add(p2hash);

        const p1Card = deck1.shift()!;
        const p2Card = deck2.shift()!;
    
        if (deck1.length >= p1Card && deck2.length >= p2Card) {
            if (play(deck1.slice(0, p1Card), deck2.slice(0, p2Card)) === Winner.Player1) {
                deck1.push(p1Card, p2Card);
            } else {
                deck2.push(p2Card, p1Card);
            }
        } else {
            if (p1Card > p2Card) {
                deck1.push(p1Card, p2Card);
            } else {
                deck2.push(p2Card, p1Card);
            }
        }
    }

    return deck1.length > 1 ? Winner.Player1 : Winner.Player2;
}

const p1Stack2 = [...player1inp];
const p2Stack2 = [...player2inp];
play(p1Stack2, p2Stack2);

const winningDeck2 = p1Stack2.length === 0 ? p2Stack2 : p1Stack2;
console.log("Part 2:", sum(winningDeck2.map((v, i) => v * (winningDeck2.length - i))));