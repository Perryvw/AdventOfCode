import { parseDataLine, minItem, measureTime } from "./common";

const imageData = parseDataLine("data/day8.data", parseInt, "");

const imageWidth = 25;
const imageHeight = 6;

function partitionLayers(imageData: number[], layerSize: number): Array<number[]> {
    return imageData.length === layerSize
        ? [imageData]
        : [imageData.slice(0, layerSize)].concat(partitionLayers(imageData.slice(layerSize), layerSize));
}

const digitCount = (digit: number) => (data: number[]) => data.filter(d => d === digit).length;

// Part 1
const layers = partitionLayers(imageData, imageWidth * imageHeight);
const layerWithLeastZeroes = minItem(layers, digitCount(0));
const checksum = digitCount(1)(layerWithLeastZeroes) * digitCount(2)(layerWithLeastZeroes);
console.log(`Part 1: ${checksum}`);

// Part 2
function mergeLayers(layer1: number[], layer2: number[]): number[] {
    return layer1.map((v, i) => v === 0 || v === 1 ? v : layer2[i]);
}
const result = layers.reduce(mergeLayers);
const image = partitionLayers(result, imageWidth)
    .map(row => row.map(d => d === 1 ? "#" : " ").join(""))
    .join("\n");
console.log(`Part 2:`);
console.log(image);