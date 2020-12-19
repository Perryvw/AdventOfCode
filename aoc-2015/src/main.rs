pub trait AoCSolution {
    fn day(&self) -> i8;
    fn part1(&self) -> String;
    fn part2(&self) -> String;
}

mod day1;
mod day2;
mod common;

fn main() {
    let time = Instant::now();

    run_solution(&day1::Solution {});
    run_solution(&day2::Solution {});
    
    println!("");
    println!("Total runtime: {}ms", time.elapsed().as_secs_f64() * 1000.0);
}

use std::time::Instant;

fn run_solution(s: &dyn AoCSolution) {
    println!("Running solution for day {}:", s.day());

    let part1_start = Instant::now();
    println!("Part 1: {} ({}ms)", s.part1(), part1_start.elapsed().as_secs_f64() * 1000.0);

    let part2_start = Instant::now();
    println!("Part 2: {} ({}ms)", s.part2(), part2_start.elapsed().as_secs_f64() * 1000.0);
}
