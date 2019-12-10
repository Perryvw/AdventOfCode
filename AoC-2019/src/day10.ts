import { maxItem, orderBy, parseData, unique } from "./common";

type Asteroid = [number, number];

const dataMap = parseData("data/day10.data", l => l.split(""));
const asteroids = dataMap.flatMap((row, y) => 
    row.map((value, x) => value === "#" ? [x, y] : undefined)
        .filter(v => v !== undefined)) as Asteroid[];

// Part 1
const angleTo = (from: Asteroid, to: Asteroid) => Math.atan2(to[1] - from[1], to[0] - from[0]);
const uniqueAngles = (point: Asteroid) => 
    unique(
        asteroids.filter(a => a !== point)
                 .map(a2 => angleTo(point, a2))
    ).length;

const bestPoint = maxItem(asteroids, a => uniqueAngles(a));
console.log(`Part 1: ${uniqueAngles(bestPoint)}`);

// Part 2
const center = bestPoint;
const asteroidsWithoutCenter = asteroids.filter(a => a !== center);
const angleOrderMetric = (asteroid: Asteroid) => (angleTo(center, asteroid) + 2.5 * Math.PI) % (2 * Math.PI);
const distanceOrderMetric = (asteroid: Asteroid) => Math.hypot(center[0] - asteroid[0], center[1] - asteroid[1]);
const orderedAsteroids = orderBy(asteroidsWithoutCenter, angleOrderMetric, distanceOrderMetric);

function vaporize(asteroids: Asteroid[], skipped: Asteroid[], prevAngle: number, toVaporize: number): Asteroid {
    return asteroids.length === 0
        ? vaporize(skipped, [], prevAngle, toVaporize)
        : prevAngle === angleTo(center, asteroids[0])
            ? vaporize(asteroids.slice(1), [...skipped, asteroids[0]], prevAngle, toVaporize)
            : toVaporize === 1
                ? asteroids[0]
                : vaporize(asteroids.slice(1), skipped, angleTo(center, asteroids[0]), toVaporize - 1);
}

const asteroid200 = vaporize(orderedAsteroids, [], -1, 200);
console.log(`Part 2: ${asteroid200[1] + asteroid200[0] * 100}`);
