import { except, intersect, parseData } from "./common";

type Product = { ingredients: string[], allergens: string[] }
function parseProduct (inp: string): Product {
    const match = /([^\(]+) \(contains ([^\)]+)\)/.exec(inp);
    return { ingredients: match![1].trim().split(" "), allergens: match![2].trim().split(", ") };
}

const products = parseData("data/day21.data", parseProduct);

const ingredientMap = new Map<string, Set<Product>>();
const allergenMap = new Map<string, Set<string>>();
for (const product of products) {
    // Add to ingredient map
    for (const ingredient of product.ingredients) {
        if (!ingredientMap.has(ingredient)) {
            ingredientMap.set(ingredient, new Set<Product>()); 
        }
        ingredientMap.get(ingredient)!.add(product);
    }

    // Add to allergen map
    for (const allergen of product.allergens) {
        if (!allergenMap.has(allergen)) {
            allergenMap.set(allergen, new Set(product.ingredients));
        } else {
            allergenMap.set(allergen, intersect(new Set(product.ingredients), allergenMap.get(allergen)!));
        }
    }
}

const allIngredients = new Set(ingredientMap.keys());
const cantContainAllergen = except(allIngredients, new Set([...allergenMap.values()].flatMap(s => [...s.values()])));

let count = 0;
cantContainAllergen.forEach(ingredient => count += ingredientMap.get(ingredient)!.size);
console.log("Part 1", count);

// Part 2
const entries = [...allergenMap.entries()];
const result: Array<{ingredient: string, allergen: string}> = [];
while (entries.some(([_, ingredients]) => ingredients.size === 1)) {
    const entryToEliminate = entries.find(([_, ingredients]) => ingredients.size === 1)!;
    const ingredientToEliminate = entryToEliminate[1].values().next().value;
    result.push({ ingredient: ingredientToEliminate, allergen: entryToEliminate[0] });

    for (const entry of entries) {
        entry[1].delete(ingredientToEliminate);
    }
}

console.log(result.sort((a, b) => a.allergen.localeCompare(b.allergen)).map(e => e.ingredient).join(","));