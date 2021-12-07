use crate::aoc::AocSolution;

pub struct Day7;

impl AocSolution for Day7 {

    fn data_path(&self) -> &str { "data/day7.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let crabs: Vec<i32> = input.split(",").map(|c| c.parse().unwrap()).collect();

        let min = *crabs.iter().min().unwrap();
        let max = *crabs.iter().max().unwrap();

        let p1 = binary_search_min(min, max, &crabs, cost_total);
        let p2 = binary_search_min(min, max, &crabs, cost_total2);

        return (p1.to_string(), p2.to_string());
    }
}

fn cost_total(crabs: &Vec<i32>, position: i32) -> i32 {
    return crabs.iter().map(|c| (c - position).abs()).sum();
}

fn cost_total2(crabs: &Vec<i32>, position: i32) -> i64 {
    return crabs.iter().map(|c| cost2((c - position).abs() as i64)).sum();
}

fn cost2(distance: i64) -> i64 {
    return (distance * (distance + 1)) / 2;
}

fn binary_search_min<TRet>(from: i32, to: i32, crabs: &Vec<i32>, costfunc: fn(&Vec<i32>, i32) -> TRet) -> TRet
    where TRet : std::cmp::Ord
{
    if from == to {
        return costfunc(crabs, from);
    }
    let mid = (from + to) / 2;
    if costfunc(crabs, mid) < costfunc(crabs, mid + 1) {
        return binary_search_min(from, mid, crabs, costfunc);
    } else {
        return binary_search_min(mid + 1, to, crabs, costfunc);
    }
}
