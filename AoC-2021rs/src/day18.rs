use crate::aoc::AocSolution;

#[derive(Clone, Copy)]
struct NumAtDepth {
    val: u32,
    depth: usize
}

pub struct Day18;

impl AocSolution for Day18 {

    fn data_path(&self) -> &str { "data/day18.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let nums: Vec<Vec<NumAtDepth>> = input.lines().map(parse).collect();

        let res = nums.iter()
            .skip(1)
            .fold(nums[0].clone(), |current, next| {
                let mut nextsum = add(&current, next);
                reduce(&mut nextsum);
                return nextsum;
            });

        let p1 = magnitude(&res);

        let p2 = nums.iter()
            .enumerate()
            .flat_map(|(i, a)|
                nums.iter()
                .enumerate()
                .filter(move |(j, _)| i != *j)
                .map(move |(_, b)| {
                    let mut nextsum = add(&a, b);
                    reduce(&mut nextsum);
                    return magnitude(&nextsum);
                })
            )
            .max()
            .unwrap();

        return (p1.to_string(), p2.to_string());
    }
}

fn magnitude(list: &Vec<NumAtDepth>) -> u32 {
    let mut maglist = list.clone();
    while maglist.len() > 1 {
        let maxdepth = maglist.iter().map(|n| n.depth).max().unwrap();
        let (index, _) = maglist.iter().enumerate().find(|(_, n)| n.depth == maxdepth).unwrap();

        let left = maglist[index].val;
        let right = maglist[index + 1].val;
        let val = (left * 3) + (right * 2);

        maglist.drain(index..=index+1);
        maglist.insert(index, NumAtDepth { val, depth: maxdepth - 1 });
    }

    return maglist[0].val;
}

fn add(left: &Vec<NumAtDepth>, right: &Vec<NumAtDepth>) -> Vec<NumAtDepth> {
    vec![left, right].iter().flat_map(|operand| {
        operand.iter().map(|NumAtDepth { val, depth }| NumAtDepth { val: *val, depth: depth + 1 })
    })
    .collect()
}

fn reduce(list: &mut Vec<NumAtDepth>) {
    while reduce_1(list) { }
}

fn reduce_1(list: &mut Vec<NumAtDepth>) -> bool {
    if let Some((index, _)) = list.iter().enumerate().find(|(_, num)| num.depth >= 5) {
        let left = list[index];
        let right = list[index + 1];
        list.drain(index..=index + 1);
        list.insert(index, NumAtDepth { val: 0, depth: left.depth - 1 });

        if let Some(leftleft) = list.get_mut(index - 1) {
            leftleft.val += left.val;
        }

        if let Some(rightright) = list.get_mut(index + 1) {
            rightright.val += right.val;
        }

        return true;
    }

    if let Some((index, num)) = list.clone().iter().enumerate().find(|(_, num)| num.val > 9) {
        list[index] = NumAtDepth { val: num.val / 2, depth: num.depth + 1 };
        list.insert(index + 1, NumAtDepth{ val: (num.val / 2) + (num.val % 2), depth: num.depth + 1 });

        return true;
    }

    return false;
}

fn parse(input: &str) -> Vec<NumAtDepth> {
    let mut result = vec![];
    let mut depth = 0;

    for b in input.as_bytes() {
        match b {
            b'[' => { depth += 1; }
            b']' => { depth -= 1; }
            b',' => {}
            _ => {
                result.push(NumAtDepth { val: (b - b'0') as u32, depth });
            }
        }
    }

    return result;
}
