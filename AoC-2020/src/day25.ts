function findLoopSize(subjectNr: number, target: number): number {
    let value = 1;
    let loopSize = 0;
    while (value !== target) {
        value *= subjectNr;
        value = value % 20201227;
        loopSize++;
    }
    return loopSize;
}

const cardPubKey = 6929599;
const doorPubKey = 2448427;

const cardLoopSize = findLoopSize(7, cardPubKey);
const doorLoopSize = findLoopSize(7, doorPubKey);

let encryptionKey = 1;
for (let i = 0; i < doorLoopSize; i++) {
    encryptionKey *= cardPubKey;
    encryptionKey = encryptionKey % 20201227;
}

console.log(encryptionKey);
