pub struct Solution {}

use crate::AoCSolution;

use crate::common;
use std::cmp::max;
use std::cmp::min;

impl AoCSolution for Solution {
    fn day(&self) -> i8 {
        2
    }

    fn part1(&self) -> String {
        let lines = common::read_lines("data/day2.data");

        lines
            .filter_map(Result::ok)
            .map(parse_line)
            .map(wrapping_paper_required)
            .sum::<i32>()
            .to_string()
    }

    fn part2(&self) -> String {
        let lines = common::read_lines("data/day2.data");

        lines
            .filter_map(Result::ok)
            .map(parse_line)
            .map(ribbon_required)
            .sum::<i32>()
            .to_string()
    }
}

fn parse_line(line: String) -> Vec<i32> {
    line.trim().split("x").map(|p| p.parse().unwrap()).collect()
}

fn wrapping_paper_required(dimensions: Vec<i32>) -> i32 {
    let a1 = dimensions[0] * dimensions[1];
    let a2 = dimensions[0] * dimensions[2];
    let a3 = dimensions[1] * dimensions[2];

    let area = 2 * a1 + 2 * a2 + 2 * a3;
    let extra = min(a1, min(a2, a3));

    area + extra
}

fn ribbon_required(dimensions: Vec<i32>) -> i32 {
    let max_side = max(dimensions[0], max(dimensions[1], dimensions[2]));
    let ribbon = 2 * dimensions[0] + 2 * dimensions[1] + 2 * dimensions[2] - 2 * max_side;
    let bow = dimensions[0] * dimensions[1] * dimensions[2];

    ribbon + bow
}
