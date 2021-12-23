use crate::aoc::AocSolution;

#[derive(Clone)]
struct Region {
    min_x: i32,
    max_x: i32,
    min_y: i32,
    max_y: i32,
    min_z: i32,
    max_z: i32,
}

#[derive(Clone)]
enum Instruction {
    On(Region),
    Off(Region)
}

pub struct Day22;

impl AocSolution for Day22 {

    fn data_path(&self) -> &str { "data/day22.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let instructions: Vec<Instruction> = input.lines().map(parse).collect();

        let p1_instructions: Vec<Instruction> = instructions.iter()
            .filter(|inst| !ignore_p1(inst))
            .map(|inst| inst.clone())
            .collect();
        let p1 = simulate(&p1_instructions);

        let p2 = simulate(&instructions);

        return (p1.to_string(), p2.to_string());
    }
}

fn simulate(instructions: &Vec<Instruction>) -> i64 {
    let mut result: Vec<Instruction> = vec![];

    for inst in instructions {
        match inst {
            Instruction::On(region) => {
                let overlaps_on: Vec<Instruction> = result.iter()
                    .filter(|i| is_on(i) && has_overlap(region, instruction_region(i)))
                    .map(|i| Instruction::Off(calculate_overlap(region, instruction_region(i))))
                    .collect();

                let overlaps_off: Vec<Instruction> = result.iter()
                    .filter(|i| !is_on(i) && has_overlap(region, instruction_region(i)))
                    .map(|i| Instruction::On(calculate_overlap(region, instruction_region(i))))
                    .collect();

                result.push(inst.clone());
                result.extend(overlaps_on);
                result.extend(overlaps_off);
            },
            Instruction::Off(region) => {
                let overlaps_on: Vec<Instruction> = result.iter()
                    .filter(|i| is_on(i) && has_overlap(region, instruction_region(i)))
                    .map(|i| Instruction::Off(calculate_overlap(region, instruction_region(i))))
                    .collect();

                let overlaps_off: Vec<Instruction> = result.iter()
                    .filter(|i| !is_on(i) && has_overlap(region, instruction_region(i)))
                    .map(|i| Instruction::On(calculate_overlap(region, instruction_region(i))))
                    .collect();

                result.extend(overlaps_on);
                result.extend(overlaps_off);
            }
        }
    }

    return result.iter()
        .map(|i| match i {
            Instruction::On(r) => volume(&r),
            Instruction::Off(r) => -volume(&r),
        })
        .sum();
}

fn ignore_p1(i: &Instruction) -> bool {
    let r = instruction_region(i);
    return r.min_x < -50 || r.max_x > 50;
}

fn instruction_region(i: &Instruction) -> &Region {
    match i {
        Instruction::On(r) => r,
        Instruction::Off(r) => r,
    }
}

fn is_on(i: &Instruction) -> bool {
    match i {
        Instruction::On(_) => true,
        Instruction::Off(_) => false,
    }
}

fn has_overlap(r1: &Region, r2: &Region) -> bool {
    r1.max_x >= r2.min_x && r1.min_x <= r2.max_x
    && r1.max_y >= r2.min_y && r1.min_y <= r2.max_y
    && r1.max_z >= r2.min_z && r1.min_z <= r2.max_z
}

fn calculate_overlap(r1: &Region, r2: &Region) -> Region {
    Region {
        min_x: std::cmp::max(r1.min_x, r2.min_x),
        max_x: std::cmp::min(r1.max_x, r2.max_x),
        min_y: std::cmp::max(r1.min_y, r2.min_y),
        max_y: std::cmp::min(r1.max_y, r2.max_y),
        min_z: std::cmp::max(r1.min_z, r2.min_z),
        max_z: std::cmp::min(r1.max_z, r2.max_z),
    }
}

fn volume(r: &Region) -> i64 {
    ((r.max_x - r.min_x + 1) as i64) * ((r.max_y - r.min_y + 1) as i64) * ((r.max_z - r.min_z + 1) as i64)
}

fn parse(line: &str) -> Instruction {
    let mut split_line = line.split(" ");
    if split_line.next().unwrap() == "on" {
        return Instruction::On(parse_region(split_line.next().unwrap()));
    } else {
        return Instruction::Off(parse_region(split_line.next().unwrap()));
    }
}

fn parse_region(r: &str) -> Region {
    let mut split_region = r.split(",");
    let (min_x, max_x) = parse_coord(split_region.next().unwrap());
    let (min_y, max_y) = parse_coord(split_region.next().unwrap());
    let (min_z, max_z) = parse_coord(split_region.next().unwrap());
    return Region { min_x, max_x, min_y, max_y, min_z, max_z }
}

fn parse_coord(c: &str) -> (i32, i32) {
    let mut split_coords = c[2..].split("..");
    return (split_coords.next().unwrap().parse().unwrap(), split_coords.next().unwrap().parse().unwrap());
}
