use crate::aoc::AocSolution;

extern crate regex;
use regex::Regex;

extern crate itertools;
use itertools::Itertools;

pub struct Day17;

impl AocSolution for Day17 {

    fn data_path(&self) -> &str { "data/day17.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let re = Regex::new(r"x=(-?\d+)..(-?\d+), y=(-?\d+)..(-?\d+)").unwrap();

        let minx= re.captures(input).unwrap()[1].parse::<i32>().unwrap();
        let maxx = re.captures(input).unwrap()[2].parse::<i32>().unwrap();
        let miny = re.captures(input).unwrap()[3].parse::<i32>().unwrap();
        let maxy = re.captures(input).unwrap()[4].parse::<i32>().unwrap();

        let velocities: Vec<(i32, i32, i32)> = (miny..=-miny).flat_map(|vely|
                (1..=-2*miny)
                    .filter(move |t| miny <= pos_at_time_y(vely, *t) && pos_at_time_y(vely, *t) <= maxy)
                    .flat_map(move |t|
                        ((minx as f32).sqrt() as i32..=maxx)
                            .filter(move |velx| minx <= pos_at_time_x(*velx, t) && pos_at_time_x(*velx, t) <= maxx)
                            .map(move |velx| (velx, vely, t))
                        )
                )
            .collect();

        let p1 = velocities.iter().map(|(_, vy, _)| sum_1_to_n(*vy)).max().unwrap();
        let p2 = velocities.iter().unique_by(|(x, y, _)| x * 10000 + y).count();

        return (p1.to_string(), p2.to_string())
    }
}

fn pos_at_time_x(velocity0: i32, t: i32) -> i32 {
    if t >= velocity0 {
        sum_1_to_n(velocity0)
    } else {
        sum_1_to_n(velocity0) - sum_1_to_n(velocity0 - t)
    }
}

fn pos_at_time_y(velocity0: i32, t: i32) -> i32 {
    sum_1_to_n(velocity0) - sum_1_to_n(velocity0 - t)
}

fn sum_1_to_n(n: i32) -> i32 {
    (n * (n + 1)) / 2
}
