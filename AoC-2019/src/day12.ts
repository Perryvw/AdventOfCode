import { lcm, parseData, sum } from "./common";

type Vector = [number, number, number];

const inputRegex = /<x=([^,]+), y=([^,]+), z=([^,]+)>/;

const initialPositions = parseData("data/day12.data", l => l.match(inputRegex)!.slice(1, 4).map(n => parseInt(n)) as Vector);

type PlanetState = { pos: Vector, vel: Vector };
type SystemState = PlanetState[];
const planets = initialPositions.map(p => ({ pos: p, vel: [0,0,0] as Vector }));

function applyGravity(planet: PlanetState, otherPlanets: PlanetState[]): PlanetState {
    const dx = sum(otherPlanets.map(p => p.pos[0] > planet.pos[0] ? 1 : p.pos[0] < planet.pos[0] ? -1 : 0));
    const dy = sum(otherPlanets.map(p => p.pos[1] > planet.pos[1] ? 1 : p.pos[1] < planet.pos[1] ? -1 : 0));
    const dz = sum(otherPlanets.map(p => p.pos[2] > planet.pos[2] ? 1 : p.pos[2] < planet.pos[2] ? -1 : 0));
    return { pos: planet.pos, vel: [planet.vel[0] + dx, planet.vel[1] + dy, planet.vel[2] + dz]};
}

function applyVelocity(planet: PlanetState): PlanetState
{
    return { pos: [
            planet.pos[0] + planet.vel[0],
            planet.pos[1] + planet.vel[1],
            planet.pos[2] + planet.vel[2]
        ] as Vector,
        vel: planet.vel
    };
}

function step(state: SystemState): SystemState {
    const gravityApplied = state.map(p => applyGravity(p, state.filter(p2 => p !== p2)));
    const velocityApplied = gravityApplied.map(applyVelocity);
    return velocityApplied;
}

function simulate(state: SystemState, steps: number): SystemState {
    return steps === 0
        ? state
        : simulate(step(state), steps - 1);
}

const potentialEnergy = (state: PlanetState) => Math.abs(state.pos[0]) + Math.abs(state.pos[1]) + Math.abs(state.pos[2]);
const kineticEnergy = (state: PlanetState) => Math.abs(state.vel[0]) + Math.abs(state.vel[1]) + Math.abs(state.vel[2]);
const energy = (state: PlanetState) => potentialEnergy(state) * kineticEnergy(state);

console.log(`Part 1: ${sum(simulate(planets, 1000).map(energy))}`);

const hash = (coord: number) => (state: SystemState) => state.map(p => `${p.pos[coord]};${p.vel[coord]}`).join(",");
const xHash = hash(0);
const yHash = hash(1);
const zHash = hash(2)

const frequencies = [undefined, undefined, undefined] as Array<number | undefined>;

const seenX = new Map<string, number>();
const seenY = new Map<string, number>();
const seenZ = new Map<string, number>();

let state = planets;
let steps = 0;
while (frequencies.some(c => c === undefined)) {
    state = step(state);
    steps++;
    if (frequencies[0] === undefined) {
        if(seenX.has(xHash(state))) {
            frequencies[0] = steps - seenX.get(xHash(state))!;
        } else {
            seenX.set(xHash(state), steps);
        }
    }
    if (frequencies[1] === undefined) {
        if(seenY.has(yHash(state))) {
            frequencies[1] = steps - seenY.get(yHash(state))!;
        } else {
            seenY.set(yHash(state), steps);
        }
    }
    if (frequencies[2] === undefined) {
        if(seenZ.has(zHash(state))) {
            frequencies[2] = steps - seenZ.get(zHash(state))!;
        } else {
            seenZ.set(zHash(state), steps);
        }
    }
}

console.log(`Part 2: ${lcm(frequencies[0]!, frequencies[1]!, frequencies[2]!)}`);
