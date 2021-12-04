use crate::aoc::AocSolution;

pub struct Day3;

const ZERO: u8 = '0' as u8;
const ONE: u8 = '1' as u8;

impl AocSolution for Day3 {

    fn data_path(&self) -> &str { "data/day3.txt" }

    fn calculate(&self, input: &String) -> (String, String) {
        let nums: Vec<&[u8]> = input.lines().map(|line| line.as_bytes()).collect();
        let bit_length = nums[0].len();

        // P1
        let gamma_bits: Vec<u8> = (0..bit_length)
            .map(|i| most_common(&nums, i))
            .collect();

        let gamma = bits_to_num(&gamma_bits);
        let epsilon = bits_to_num(&gamma_bits.iter().map(|b| flip(b)).collect::<Vec<u8>>());

        // P2
        let o2gen = find(&nums, 0, true);
        let co2scrub = find(&nums, 0, false);

        return ((gamma * epsilon).to_string(), (o2gen * co2scrub).to_string());
    }
}

fn flip(v: &u8) -> u8 {
    if *v == ZERO { ONE } else { ZERO }
}

fn most_common(nums: &Vec<&[u8]>, index: usize) -> u8 {
    if nums.iter().filter(|v| v[index] == ZERO).count() > (nums.len() / 2)
    { ZERO }
    else
    { ONE }
}

fn bits_to_num(bits: &[u8]) -> u32 {
    return bits.iter()
        .rev()
        .enumerate()
        .fold(0, |sum, (i, v)| sum + (((v-ZERO) as u32) << i));
}

fn find(nums: &Vec<&[u8]>, i: usize, use_most: bool) -> u32 {
    if nums.len() == 1 {
        return bits_to_num(nums.first().unwrap());
    } else {
        let filter_bit = if use_most { most_common(nums, i) } else { flip(&most_common(nums, i)) };
        let filtered: Vec<&[u8]> = nums.iter().filter(|v| v[i] == filter_bit).cloned().collect();
        return find(&filtered, i + 1, use_most);
    }
}
