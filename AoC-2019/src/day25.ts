import * as readline from "readline";
import { allSubsets, parseDataLine } from "./common";
import { addProgramInput, clearOutput, execute, programFromMemoryAndInput, ProgramState } from "./intcode";

const cli = readline.createInterface({ input: process.stdin, output: process.stdout, terminal: false });

const program = parseDataLine("data/day25.data", parseInt);

const gatherItemsInput = 
`west
north
take dark matter
south
east
north
west
take planetoid
west
take spool of cat6
east
east
south
east
north
take sand
west
take coin
north
take jam
south
west
south
take wreath
west
take fuel cell
east
north
north
west
`;

const items = [
    "dark matter",
    "planetoid",
    "spool of cat6",
    "sand",
    "coin",
    "jam",
    "wreath",
    "fuel cell"
];

const encodeString = (str: string) => [...str].map(c => c.charCodeAt(0));
const decodeString = (nrs: number[]) => String.fromCharCode(...nrs);

let state: ProgramState = programFromMemoryAndInput(program, encodeString(gatherItemsInput));
state = execute(state);
console.log(decodeString(state.output));

const dropAllItems = (pState: ProgramState) =>
    execute(addProgramInput(pState, ...encodeString(items.map(item => `drop ${item}\n`).join(""))));

const pickUpItems = (pState: ProgramState, pickup: string[]) =>
    execute(addProgramInput(pState, ...encodeString(pickup.map(item => `take ${item}\n`).join(""))));

const itemCombinations = allSubsets(items);

for (const combination of itemCombinations) {
    // Get items
    state = dropAllItems(state);
    state = pickUpItems(state, combination);
    // Try combination
    state = execute(addProgramInput(clearOutput(state), ...encodeString("south\n")));
    const output = decodeString(state.output);
    if (!output.includes("heavier") && !output.includes("lighter")) {
        console.log(combination);
        console.log(output);
        break;
    }
}


/*cli.on("line", (line: string) => {
    state = execute(addProgramInput(clearOutput(state), ...encodeString(line + "\n")));
    console.log(decodeString(state.output));
})*/
/*while (!state.done) {
    console.log(String.fromCharCode(...state.output));
    readline.
}*/
