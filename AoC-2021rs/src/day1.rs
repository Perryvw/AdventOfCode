use crate::aoc::AocSolution;

pub struct Day1;

impl AocSolution for Day1 {

    fn data_path(&self) -> &str { "data/day1.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let nums: Vec<i32> = input
            .lines()
            .map(|line| line.parse::<i32>().unwrap())
            .collect();

        let p1 = nums
            .windows(2)
            .filter(|window| window[0] < window[1])
            .count();

        let p2 = nums
            .windows(4)
            .filter(|window| window[0] < window[3])
            .count();

        return (p1.to_string(), p2.to_string());
    }
}