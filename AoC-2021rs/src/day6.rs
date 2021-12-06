use crate::aoc::AocSolution;

pub struct Day6;

impl AocSolution for Day6 {

    fn data_path(&self) -> &str { "data/day6.txt" }

    fn calculate(&self, input: &String) -> (String, String) {
        let mut fish: [u64; 9] = [0; 9];

        for n in input.split(",").map(|s| s.parse::<usize>().unwrap()) {
            fish[n] += 1;
        }

        for _ in 0..80 { update(&mut fish); }
        let p1: u64 = fish.iter().sum();

        for _ in 0..(256 - 80) { update(&mut fish); }
        let p2: u64 = fish.iter().sum();

        return (p1.to_string(), p2.to_string());
    }
}

fn update(fish: &mut [u64; 9]) {
    let newfish = fish[0];

    for i in 0..8 {
        fish[i] = fish[i + 1];
    }

    fish[6] +=  newfish;
    fish[8] = newfish;
}
