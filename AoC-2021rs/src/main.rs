mod aoc;
mod common;
mod day1;
mod day2;
mod day3;
mod day4;
mod day5;
use std::{fs::File, io::Read};

extern crate lazy_static;

const REPETITIONS: i32 = 200;

const FOCUS: bool = false;

fn main() {
    if FOCUS {
        // RUN A SINGLE DAY ONCE
        let single: Box<dyn aoc::AocSolution> = Box::new(day5::Day5);
        println!("\n\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n");
        run_day(&single, 1);
        println!("\n >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \n");
    }
        else {
        // RUN ALL DAYS
        let all_days: Vec<Box<dyn aoc::AocSolution>> = vec![
            Box::new(day1::Day1),
            Box::new(day2::Day2),
            Box::new(day3::Day3),
            Box::new(day4::Day4),
            Box::new(day5::Day5),
        ];
        run_days(all_days);
    }
}

fn run_day(answer: &Box<dyn aoc::AocSolution>, repetitions: i32) -> f64 {

    let mut duration = std::time::Duration::from_secs(0);

    let mut data_buffer: String = String::new();
    File::open(answer.data_path()).unwrap().read_to_string(&mut data_buffer).expect("Failed to open data file");

    let (p1, p2) = answer.calculate(&data_buffer);

    for _ in 1..repetitions {
        let start = std::time::Instant::now();
        answer.calculate(&data_buffer);
        duration += start.elapsed();
    }

    let avg_duration = duration.as_secs_f64() / (repetitions as f64);

    println!("{} - p1: {} - p2: {} - duration: {}ms", answer.data_path(), p1, p2, avg_duration * 1000.0);

    return avg_duration;
}

fn run_days(days: Vec<Box<dyn aoc::AocSolution>>) {

    println!("\nRunning all 2021 days ({} repetitions):\n", REPETITIONS);

    let total_duration: f64 = days.iter()
        .map(|day| run_day(day, REPETITIONS))
        .sum();

    println!("\nTotal duration: {}ms", total_duration * 1000.0);
}