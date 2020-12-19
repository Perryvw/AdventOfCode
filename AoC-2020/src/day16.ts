import { enumerate, product, readData, sum, transpose } from "./common";

const data = readData("data/day16.data").split("\n\n");

type Field = { name: string, range1: [number, number], range2: [number, number] };

function parseField(inp: string): Field {
    const split = inp.split(":");
    const name = split[0].trim();
    const ranges = split[1].split(" or ");
    const range1 = /(\d+)-(\d+)/.exec(ranges[0]);
    const range2 = /(\d+)-(\d+)/.exec(ranges[1]);

    return {
        name,
        range1: [parseInt(range1![1]), parseInt(range1![2])],
        range2: [parseInt(range2![1]), parseInt(range2![2])],
    };
}

const fields = data[0].split("\n").map(parseField);
const ticket = data[1].split("\n")[1].split(",").map(v => parseInt(v));
const nearbyTickets = data[2].split("\n").slice(1).map(l => l.split(",").map(v => parseInt(v)));

// Part 1
const isInvalidNumber = (n: number) => !fields.some(f => (n >= f.range1[0] && n <= f.range1[1]) || (n >= f.range2[0] && n <= f.range2[1]));
const invalidNumbers = nearbyTickets.flat().filter(isInvalidNumber);
console.log("Part 1:", sum(invalidNumbers));

// Part 2
const validTickets = [ticket, ...nearbyTickets.filter(ticket => !ticket.some(isInvalidNumber))];

const columns = transpose(validTickets);

const isInField = (field: Field) => (n: number) => (n >= field.range1[0] && n <= field.range1[1]) || (n >= field.range2[0] && n <= field.range2[1]);

const validFieldsPerColumn = columns.map(vals => new Set(fields.filter(f => vals.every(isInField(f)))));

const result: Field[] = [];

// Keep going until all possibilities are done
while (validFieldsPerColumn.some(fs => fs.size > 0)) {
    // Find column with only single possible field
    const columnIndex = validFieldsPerColumn.findIndex(column => column.size === 1)!;
    const fieldToEliminate = validFieldsPerColumn[columnIndex].values().next().value;    
    result[columnIndex] = fieldToEliminate;

    // Remove field possibility from all other columns
    for (const column of validFieldsPerColumn) {
        column.delete(fieldToEliminate);
    }
}

const departureIndices = enumerate(result).filter(([i, f]) => f.name.startsWith("departure"));
const p2Result = product(departureIndices.map(([i, f]) => ticket[i]));

console.log("Part 2:", p2Result);

