use hashbrown::HashSet;

use crate::{aoc::AocSolution, common::GridInfo};

use std::collections::BinaryHeap;

type Pos = (usize, usize);

#[derive(Eq, PartialEq)]
struct State {
    cost: usize,
    path: Vec<Pos>
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
       Some(self.cmp(other))
    }
}

pub struct Day15;

impl AocSolution for Day15 {

    fn data_path(&self) -> &str { "data/day15.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let costs: Vec<Vec<usize>> = input.lines().map(|l| l.as_bytes().iter().map(|b| (b - b'0') as usize).collect()).collect();

        let grid = GridInfo::new(costs[0].len(), costs.len());

        let p1_result = p1(&costs, &grid);

        let p2_result = p2(&costs, &grid);

        return (p1_result.to_string(), p2_result.to_string())
    }
}

fn p1(costs: &Vec<Vec<usize>>, grid: &GridInfo) -> usize {
    let goal = (grid.width - 1, grid.height - 1);

    let mut bin_heap = BinaryHeap::new();

    let mut seen = HashSet::new();
    seen.insert((0, 0));

    bin_heap.push(State{ cost: 0, path: vec![(0,0)] });

    while let Some(State{ cost, path }) = bin_heap.pop() {
        let current_pos = path.last().unwrap();
        if current_pos == &goal {
            return path.iter().skip(1).map(|(x, y)| costs[*y][*x]).sum::<usize>();
        }

        for (nx, ny) in grid.neighbours(current_pos.0, current_pos.1) {
            if !seen.contains(&(nx, ny)) {
                let mut new_path = path.clone();
                new_path.push((nx, ny));
                bin_heap.push(State{ cost: cost + costs[ny][nx], path: new_path });
                seen.insert((nx, ny));
            }
        }
    }

    return 0;
}

fn p2(costs: &Vec<Vec<usize>>, grid1: &GridInfo) -> usize {
    let grid = GridInfo::new(grid1.width * 5, grid1.height * 5);
    let goal = (grid.width - 1, grid.height - 1);

    let mut bin_heap = BinaryHeap::new();

    let mut seen = HashSet::new();
    seen.insert((0, 0));

    bin_heap.push(State{ cost: 0, path: vec![(0,0)] });

    while let Some(State{ cost, path }) = bin_heap.pop() {
        let current_pos = path.last().unwrap();
        if current_pos == &goal {
            return path.iter().skip(1).map(|(x, y)| cost2(*x, *y, costs, grid1)).sum::<usize>();
        }

        for (nx, ny) in grid.neighbours(current_pos.0, current_pos.1) {
            if !seen.contains(&(nx, ny)) {
                let mut new_path = path.clone();
                new_path.push((nx, ny));
                bin_heap.push(State{ cost: cost + cost2(nx, ny, costs, grid1), path: new_path });
                seen.insert((nx, ny));
            }
        }
    }

    return 0;
}

fn cost2(x: usize, y: usize, costs: &Vec<Vec<usize>>, grid: &GridInfo) -> usize {
    ((costs[y % grid.height][x % grid.width] + (x / grid.width) + (y / grid.height) - 1) % 9) + 1
}
