use crate::aoc::AocSolution;
use crate::common::GridInfo;

#[derive(PartialEq, Eq)]
enum Cucumber {
    None,
    Down,
    Right
}

pub struct Day25;

impl AocSolution for Day25 {

    fn data_path(&self) -> &str { "data/day25.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let cucumbers: Vec<Vec<Cucumber>> = input.lines().map(parse).collect();
        let grid = GridInfo::new(cucumbers[0].len(), cucumbers.len());

        let mut next = step(&cucumbers, &grid);
        let mut steps = 1;

        while next.0 {
            next = step(&next.1, &grid);
            steps += 1;
        }

        return (steps.to_string(), String::from("n/a"))
    }
}

fn step(state: &Vec<Vec<Cucumber>>, grid: &GridInfo) -> (bool, Vec<Vec<Cucumber>>) {
    let mut new_state = empty_state(grid);

    let cucumbers_moving_east = state.iter()
        .enumerate()
        .flat_map(|(y, row)|
            row.iter()
            .enumerate()
            .filter(|(_, c)| **c == Cucumber::Right)
            .map(move |(x, _)| (x, y)));

    let cucumbers_moving_south = state.iter()
        .enumerate()
        .flat_map(|(y, row)|
            row.iter()
            .enumerate()
            .filter(|(_, c)| **c == Cucumber::Down)
            .map(move |(x, _)| (x, y)));

    let mut changed = false;

    for (x, y) in cucumbers_moving_east {
        let new_x = (x + 1) % grid.width;
        if state[y][new_x] == Cucumber::None {
            new_state[y][new_x] = Cucumber::Right;
            changed = true;
        } else {
            new_state[y][x] = Cucumber::Right;
        }
    }

    for (x, y) in cucumbers_moving_south {
        let new_y = (y + 1) % grid.height;
        if state[new_y][x] != Cucumber::Down && new_state[new_y][x] == Cucumber::None {
            new_state[new_y][x] = Cucumber::Down;
            changed = true;
        } else {
            new_state[y][x] = Cucumber::Down;
        }
    }

    return (changed, new_state);
}

fn empty_state(grid: &GridInfo) -> Vec<Vec<Cucumber>> {
    (0..grid.height).map(|_|
        (0..grid.width).map(|_| Cucumber::None).collect()
    ).collect()
}

fn parse(line: &str) -> Vec<Cucumber> {
    line.as_bytes().iter().map(|b| match b {
        b'.' => Cucumber::None,
        b'v' => Cucumber::Down,
        b'>' => Cucumber::Right,
        _ => panic!()
    })
    .collect()
}
