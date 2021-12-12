#[macro_use]
extern crate lazy_static;

mod aoc;
mod common;
mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
mod day6;
mod day7;
mod day8;
mod day9;
mod day10;
mod day11;
mod day12;
use std::{fs::File, io::Read};

const FOCUS: bool = false;

fn main() {
    if FOCUS {
        // RUN A SINGLE DAY ONCE
        let single: Box<dyn aoc::AocSolution> = Box::new(day12::Day12);
        println!("\n\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n");
        run_day(&single, 1);
        println!("\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n");
    }
        else {
        // RUN ALL DAYS
        let all_days: Vec<(Box<dyn aoc::AocSolution>, u16)> = vec![
            (Box::new(day1::Day1), 1000),
            (Box::new(day2::Day2), 1000),
            (Box::new(day3::Day3), 1000),
            (Box::new(day4::Day4), 1000),
            (Box::new(day5::Day5), 1000),
            (Box::new(day6::Day6), 1000),
            (Box::new(day7::Day7), 1000),
            (Box::new(day8::Day8), 100),
            (Box::new(day9::Day9), 100),
            (Box::new(day10::Day10), 1000),
            (Box::new(day11::Day11), 100),
            (Box::new(day12::Day12), 5),
        ];
        run_days(all_days);
    }
}

fn run_day(answer: &Box<dyn aoc::AocSolution>, repetitions: u16) -> f64 {

    let mut data_buffer: String = String::new();
    File::open(answer.data_path()).unwrap().read_to_string(&mut data_buffer).expect("Failed to open data file");

    let (p1, p2) = answer.calculate(&data_buffer);

    let durations: Vec<std::time::Duration> = (1..repetitions).map(|_| {
        let start = std::time::Instant::now();
        answer.calculate(&data_buffer);
        return start.elapsed();
    }).collect();

    let avg_duration: f64 = durations.iter().map(|d| d.as_secs_f64()).sum::<f64>() * 1000f64 / durations.len() as f64;
    let min_duration = durations.iter().min().unwrap().as_secs_f64() * 1000f64;
    let max_duration = durations.iter().max().unwrap().as_secs_f64() * 1000f64;

    println!("{:15} | p1: {:15} | p2: {:15} | average duration: {:.4}ms ({:4} repetitions)  | min: {:.4}ms  | max: {:.4}ms", answer.data_path(), p1, p2, avg_duration, repetitions, min_duration, max_duration);

    return avg_duration;
}

fn run_days(days: Vec<(Box<dyn aoc::AocSolution>, u16)>) {

    println!("\nRunning all 2021 days:\n");

    let total_duration: f64 = days.iter()
        .map(|(day, repetitions)| run_day(day, *repetitions))
        .sum();

    println!("\nTotal average duration: {}ms", total_duration);
}