use hashbrown::HashMap;
use itertools::Itertools;

use crate::aoc::AocSolution;

type Point = (i16, i16, i16);
type Orientation = (i8, i8, i8);

pub struct Day19;

impl AocSolution for Day19 {

    fn data_path(&self) -> &str { "data/day19.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let scanners: Vec<Vec<Point>> = input.split("\r\n\r\n")
            .map(parse)
            .collect();

        let scanner_matches: Vec<(usize, usize, Vec<(usize, usize)>)> = scanners.iter()
            .enumerate()
            .combinations(2)
            .map(|combination| (combination[0].0, combination[1].0, matches(combination[0].1, combination[1].1)))
            .filter(|(_, _, matches)| matches.len() >= 12)
            .collect();

        let mut scanner_positions = HashMap::<usize, Point>::new();
        scanner_positions.insert(0, (0, 0, 0));
        let mut scanner_orientations = HashMap::<usize, Orientation>::new();
        scanner_orientations.insert(0, (1, 2, 3));

        let mut q: Vec<usize> = vec![0];

        while !q.is_empty() {
            let base = q.pop().unwrap();
            // Find descendants
            for (matched_scanner, beacon_matches) in scanner_matches.iter().filter_map(|(i, j, matches)| if *i == base { Some((j, matches.clone())) } else if *j == base { Some((i, transpose(matches))) } else { None }) {
                if !scanner_positions.contains_key(matched_scanner) {
                    q.push(*matched_scanner);

                    let base_position = scanner_positions.get(&base).unwrap();
                    let base_orientation = scanner_orientations.get(&base).unwrap();

                    let beacon1 = scanners[base][beacon_matches[0].0];
                    let beacon2 = scanners[*matched_scanner][beacon_matches[0].1];

                    // Grab 2 matching points
                    let (m1, m2) = beacon_matches[0];
                    let (m3, m4) = beacon_matches[1];

                    let diff1 = sub(&scanners[base][m3], &scanners[base][m1]);
                    let diff2 = sub(&scanners[*matched_scanner][m4],  &scanners[*matched_scanner][m2]);

                    // Calculate current scanner pos relative to base
                    let scanner_orientation = orientation(&diff1, &diff2);
                    let scanner_position = sub(&beacon1, &orient(&beacon2, &scanner_orientation));

                    // Calculate absolute scanner position
                    let oriented_scanner_position = orient(&scanner_position, &base_orientation);
                    let abs_scanner_position = add(base_position, &oriented_scanner_position);

                    let abs_orientation = orient_orientation(&scanner_orientation, &base_orientation);

                    scanner_orientations.insert(*matched_scanner, abs_orientation);
                    scanner_positions.insert(*matched_scanner, abs_scanner_position);
                }
            }
        }

        let mut vecs = vec![];

        for (scanner_id, beacons) in scanners.iter().enumerate() {
            let (sx, sy, sz) = scanner_positions.get(&scanner_id).unwrap();
            //println!("---- scanner at {},{},{}", sx, sy, sz);
            for beacon in beacons {
                let (x, y, z) = add(&(*sx, *sy, *sz), &orient(beacon, scanner_orientations.get(&scanner_id).unwrap()));
                //println!("{},{},{}", x, y, z);
                vecs.push((x, y, z));
            }
        }

        let p1 = vecs.iter()
            .unique_by(|(x, y, z)| *x as i64 * 100000000 + *y as i64 * 10000 + *z as i64)
            .count();

        let p2 = scanner_positions.iter()
            .combinations(2)
            .map(|scanners| length(&sub(scanners[0].1, scanners[1].1)))
            .max()
            .unwrap();

        return (p1.to_string(), p2.to_string())
    }
}

fn transpose(matches: &Vec<(usize, usize)>) -> Vec<(usize, usize)> {
    matches.iter().map(|(i, j)| (*j, *i)).collect()
}

fn orientation(p1: &Point, p2: &Point) -> Orientation {
    (
        if p1.0 == p2.0 { 1 } else if p1.0 == p2.1 { 2 } else if p1.0 == p2.2 { 3 } else if p1.0 == -p2.0 { -1 } else if p1.0 == -p2.1 { -2 } else if p1.0 == -p2.2 { -3 } else { panic!("not good") },
        if p1.1 == p2.0 { 1 } else if p1.1 == p2.1 { 2 } else if p1.1 == p2.2 { 3 } else if p1.1 == -p2.0 { -1 } else if p1.1 == -p2.1 { -2 } else if p1.1 == -p2.2 { -3 } else { panic!("not good") },
        if p1.2 == p2.0 { 1 } else if p1.2 == p2.1 { 2 } else if p1.2 == p2.2 { 3 } else if p1.2 == -p2.0 { -1 } else if p1.2 == -p2.1 { -2 } else if p1.2 == -p2.2 { -3 } else { panic!("not good") },
    )
}

fn orient(p: &Point, orientation: &Orientation) -> Point {
    (
        if orientation.0 == 1 { p.0 } else if orientation.0 == -1 { -p.0 } else if orientation.0 == 2 { p.1 } else if orientation.0 == -2 { -p.1 } else if orientation.0 == 3 { p.2 } else if orientation.0 == -3 { -p.2 } else { panic!("not good") },
        if orientation.1 == 1 { p.0 } else if orientation.1 == -1 { -p.0 } else if orientation.1 == 2 { p.1 } else if orientation.1 == -2 { -p.1 } else if orientation.1 == 3 { p.2 } else if orientation.1 == -3 { -p.2 } else { panic!("not good") },
        if orientation.2 == 1 { p.0 } else if orientation.2 == -1 { -p.0 } else if orientation.2 == 2 { p.1 } else if orientation.2 == -2 { -p.1 } else if orientation.2 == 3 { p.2 } else if orientation.2 == -3 { -p.2 } else { panic!("not good") },
    )
}

fn orient_orientation(p: &Orientation, orientation: &Orientation) -> Orientation {
    (
        if orientation.0 == 1 { p.0 } else if orientation.0 == -1 { -p.0 } else if orientation.0 == 2 { p.1 } else if orientation.0 == -2 { -p.1 } else if orientation.0 == 3 { p.2 } else if orientation.0 == -3 { -p.2 } else { panic!("not good") },
        if orientation.1 == 1 { p.0 } else if orientation.1 == -1 { -p.0 } else if orientation.1 == 2 { p.1 } else if orientation.1 == -2 { -p.1 } else if orientation.1 == 3 { p.2 } else if orientation.1 == -3 { -p.2 } else { panic!("not good") },
        if orientation.2 == 1 { p.0 } else if orientation.2 == -1 { -p.0 } else if orientation.2 == 2 { p.1 } else if orientation.2 == -2 { -p.1 } else if orientation.2 == 3 { p.2 } else if orientation.2 == -3 { -p.2 } else { panic!("not good") },
    )
}

fn matches(first: &Vec<Point>, second: &Vec<Point>) -> Vec<(usize, usize)> {
    let first_sizes: Vec<(usize, usize, Point)> = first.iter()
        .enumerate()
        .combinations(2)
        .map(|combination| (combination[0].0, combination[1].0, sub(combination[1].1, combination[0].1)))
        .collect();
    let second_sizes: Vec<(usize, usize, Point)> = second.iter()
        .enumerate()
        .combinations(2)
        .map(|combination| (combination[0].0, combination[1].0, sub(combination[1].1, combination[0].1)))
        .collect();

    let matches: Vec<(usize, usize, usize, usize, bool)> = first_sizes
        .iter()
        .flat_map(|(i, j, diff1)| second_sizes.iter()
            .map(move |(k, l, diff2)| (*i, *j, *k, *l, does_match(diff1, diff2)))
        )
        .filter(|(_,_,_,_, include)| *include)
        .collect();

    let mut possibilities = HashMap::<usize, Vec<usize>>::new();

    for (i, j, k, l, _) in matches {
        if let Some(list) = possibilities.get(&i) {
            if list.len() == 2 {
                if list.contains(&k) { possibilities.insert(i, vec![k]); }
                else if list.contains(&l) { possibilities.insert(i, vec![l]); }
            }
        } else {
            possibilities.insert(i, vec![k, l]);
        }

        if let Some(list) = possibilities.get(&j) {
            if list.len() == 2 {
                if list.contains(&k) { possibilities.insert(j, vec![k]); }
                else if list.contains(&l) { possibilities.insert(j, vec![l]); }
            }
        } else {
            possibilities.insert(j, vec![k, l]);
        }
    }

    return possibilities.iter().map(|(k, vals)| (*k, vals[0])).collect();
}



fn does_match(p1: &Point, p2: &Point) -> bool {
    (p1.0.abs() == p2.0.abs() || p1.0.abs() == p2.1.abs() || p1.0.abs() == p2.2.abs())
    && (p1.1.abs() == p2.0.abs() || p1.1.abs() == p2.1.abs() || p1.1.abs() == p2.2.abs())
    && (p1.2.abs() == p2.0.abs() || p1.2.abs() == p2.1.abs() || p1.2.abs() == p2.2.abs())
}

fn parse(scanner_lines: &str) -> Vec<Point> {
    return scanner_lines.lines()
        .skip(1)
        .map(|line| {
            let mut split_line = line.split(",");
            return (
                split_line.next().unwrap().parse().unwrap(),
                split_line.next().unwrap().parse().unwrap(),
                split_line.next().unwrap().parse().unwrap(),
            );
        })
        .collect();
}

fn add(p1: &Point, p2: &Point) -> Point {
    (p1.0 + p2.0, p1.1 + p2.1, p1.2 + p2.2)
}

fn sub(p1: &Point, p2: &Point) -> Point {
    (p1.0 - p2.0, p1.1 - p2.1, p1.2 - p2.2)
}

fn length(p: &Point) -> i16 {
    p.0.abs() + p.1.abs() + p.2.abs()
}
