use crate::aoc::AocSolution;

pub struct Day14;

type LookupLayer = [[[u64; 26]; 26]; 26];
type PolymerMap = [[usize; 26]; 26];

impl AocSolution for Day14 {

    fn data_path(&self) -> &str { "data/day14.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut split_input = input.split("\r\n\r\n");
        let template = split_input.next().unwrap();

        // Read mapping of pairs to inserted char
        let mut polymer_map = [[0; 26]; 26];
        for (left, right, result) in split_input.next().unwrap().lines().map(parse_rule) {
            polymer_map[left][right] = result;
        }

        // Precompute lookup table
        let after_steps = 40;
        let lookup = build_lookup(after_steps + 1, &polymer_map);

        // Simply look up answers in pre-computed lookup table
        let result_p1 = lookup_template(template, 10, &lookup);
        let max_p1 = result_p1.iter().max().unwrap();
        let min_p1 = result_p1.iter().filter(|v| **v > 0).min().unwrap();
        let p1 = max_p1 - min_p1;

        let result_p2 = lookup_template(template, 40, &lookup);
        let max_p2 = result_p2.iter().max().unwrap();
        let min_p2 = result_p2.iter().filter(|v| **v > 0).min().unwrap();
        let p2 = max_p2 - min_p2;

        return (p1.to_string(), p2.to_string());
    }
}

fn lookup_template(template: &str, depth: usize, lookup: &Vec<LookupLayer>) -> [u64; 26] {
    let mut result = [0; 26];

    (0..template.len() - 1).for_each(|i| {
        let left = char_index(template.chars().nth(i).unwrap());
        let right = char_index(template.chars().nth(i + 1).unwrap());
        for i in 0..26 as usize { result[i] += lookup[depth as usize][left][right][i] }

        if i > 0 { result[left] -= 1; } // Avoid counting left char twice
    });

    return result;
}

fn build_lookup(depth: u16, polymer_map: &PolymerMap) -> Vec<LookupLayer> {
    // Dynamic programming: First make the 0th layer
    let mut initial_layer: LookupLayer = [[[0; 26]; 26]; 26];
    (0..26 as usize).for_each(|left| (0..26 as usize).for_each(|right| {
        initial_layer[left][right][left] += 1;
        initial_layer[left][right][right] += 1;
    }));

    let mut lookup = vec![initial_layer];

    // Dynamic programming: Build lookup for layers up to required depth
    // counts(left, right, depth) = counts(left, middle, depth - 1) + counts(middle, right, depth - 1) - 1x middle char
    for d in 1..depth as usize {
        let mut next_layer: LookupLayer = [[[0; 26]; 26]; 26];

        for left in 0..26 {
            for right in 0..26 {
                let middle = polymer_map[left][right];
                let prev_depth_first_middle = lookup[d - 1][left][middle];
                let prev_depth_middle_second = lookup[d - 1][middle][right];

                for i in 0..26 as usize {
                    next_layer[left][right][i] = prev_depth_first_middle[i] + prev_depth_middle_second[i];
                }
                // only count middle char once
                next_layer[left][right][middle] -= 1;
            }
        }

        lookup.push(next_layer);
    }

    return lookup;
}

fn parse_rule(rule: &str) -> (usize, usize, usize) {
    let b = rule.as_bytes();
    return ((b[0] - b'A') as usize, (b[1] - b'A') as usize, (b[6] - b'A') as usize);
}

fn char_index(c: char) -> usize {
    return c as usize - 'A' as usize;
}
