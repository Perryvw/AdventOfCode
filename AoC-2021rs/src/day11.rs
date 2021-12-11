use crate::{aoc::AocSolution, common::GridInfo};

pub struct Day11;

impl AocSolution for Day11 {

    fn data_path(&self) -> &str { "data/day11.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut vals: Vec<Vec<u8>> = input.lines().map(|l| l.as_bytes().iter().map(|b| b - b'0').collect()).collect();
        let mut vals2: Vec<Vec<u8>> = input.lines().map(|l| l.as_bytes().iter().map(|b| b - b'0').collect()).collect();

        let grid_info = GridInfo::new(vals[0].len(), vals.len());

        let p1: usize = (1..=100).map(|_| update(&mut vals, &grid_info)).sum();

        let p2: usize = (1..1000).find(|_| update(&mut vals2, &grid_info) == 100).unwrap();

        return (p1.to_string(), p2.to_string());
    }
}

fn update(grid: &mut Vec<Vec<u8>>, grid_info: &GridInfo) -> usize {
    grid.iter_mut().for_each(|line|line.iter_mut().for_each(|v| *v += 1));

    let mut seen = [false; 100];

    let mut to_flash: Vec<(usize, usize)> = grid_info.coords()
        .filter(|(x, y)| !seen[hash(*x, *y)] && grid[*y][*x] > 9)
        .collect();

    while !to_flash.is_empty() {
        for (x, y) in to_flash.iter() {
            grid[*y][*x] += 1;
            seen[hash(*x, *y)] = true;
        }

        for (x, y) in to_flash.iter().flat_map(|(x, y)| grid_info.neighbours_diag(*x, *y)) {
            grid[y][x] += 1;
        }

        to_flash = grid_info.coords()
            .filter(|(x, y)| !seen[hash(*x, *y)] && grid[*y][*x] > 9)
            .collect();
    }

    for (x, y) in seen.iter().enumerate().filter(|(_, flashed)| **flashed).map(|(i, _)| unhash(i)) {
        grid[y][x] = 0;
    }

    return seen.iter().filter(|v| **v).count();
}

fn hash(x: usize, y: usize) -> usize {
    return x * 10 + y;
}

fn unhash(hash: usize) -> (usize, usize) {
    return (hash / 10, hash % 10);
}
