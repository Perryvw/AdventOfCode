use std::collections::VecDeque;

use crate::aoc::AocSolution;

type Coord = (usize, usize);

pub struct Day9;

impl AocSolution for Day9 {

    fn data_path(&self) -> &str { "data/day9.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let grid: Vec<Vec<u8>> = input.lines().map(|l| l.as_bytes().iter().map(|b| b - '0' as u8).collect()).collect();

        let width = grid[0].len();
        let height = grid.len();

        let minima: Vec<Coord> = (0..width).flat_map(|x|
            (0..height).map(move |y| (x, y)).filter(|(x, y)| smaller_than_neighbours(*x, *y, &grid))
        ).collect();

        let p1: u32 = minima.iter()
            .map(|(x, y)| (grid[*y][*x] + 1) as u32)
            .sum();

        let mut regions = find_basins(&grid);
        regions.sort();

        let p2: usize = regions.iter().rev().take(3).product();

        return (p1.to_string(), p2.to_string());
    }
}

fn smaller_than_neighbours(x: usize, y: usize, grid: &Vec<Vec<u8>>) -> bool {
    let v = grid[y][x];
    return
        (x == 0 || v < grid[y][x - 1]) &&
        (x == grid[0].len() - 1 || v < grid[y][x + 1]) &&
        (y == 0 || v < grid[y - 1][x]) &&
        (y == grid.len() - 1 || v < grid[y + 1][x]);
}

fn find_basins(grid: &Vec<Vec<u8>>) -> Vec<usize> {
    let mut seen = Box::<[bool; 1000000]>::from([false; 1000000]);

    return (0..grid[0].len()).flat_map(|x| (0..grid.len()).map(move |y| (x, y)))
        .filter_map(|(x, y)| {
            if grid[y][x] < 9 && !seen[hash(x, y)] {
                Some(region_around(x, y, grid, &mut seen))
            }
            else { None }
        })
        .collect();
}

fn region_around(x: usize, y: usize, grid: &Vec<Vec<u8>>, seen: &mut[bool; 1000000]) -> usize {
    let mut q = VecDeque::default();
    q.push_back((x, y));

    let mut size = 0;

    while !q.is_empty() {
        let (x, y) = q.pop_front().unwrap();

        for (nx, ny) in neighbours(x, y, grid[0].len(), grid.len()) {
            if grid[ny][nx] < 9 && !seen[hash(nx, ny)] {
                seen[hash(nx, ny)] = true;
                size += 1;
                q.push_back((nx, ny));
            }
        }
    }

    return size;
}

fn neighbours(x: usize, y: usize, width: usize, height: usize) -> Vec<Coord> {
    let mut coords: Vec<Coord> = vec![];
    if y > 0 { coords.push((x, y - 1)) }
    if x < width - 1 { coords.push((x + 1, y)) }
    if y < height - 1 { coords.push((x, y + 1)) }
    if x > 0 { coords.push((x - 1, y)) }
    return coords;
}

fn hash(x: usize, y: usize) -> usize {
    return x * 1000 + y;
}
