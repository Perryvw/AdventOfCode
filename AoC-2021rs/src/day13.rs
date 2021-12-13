use crate::aoc::AocSolution;

extern crate itertools;
use itertools::Itertools;

pub struct Day13;

enum Fold {
    AlongX(usize),
    AlongY(usize)
}

impl AocSolution for Day13 {

    fn data_path(&self) -> &str { "data/day13.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut split_input = input.split("\r\n\r\n");
        let points = parse_points(split_input.next().unwrap());
        let folds = parse_folds(split_input.next().unwrap());

        let p1 = fold(points.clone(), &folds[0]).iter().unique().count();

        let p2 = folds.iter().fold(points, fold);

        let max_x = p2.iter().map(|(x, _)| *x).max().unwrap();
        let max_y = p2.iter().map(|(_, y)| *y).max().unwrap();

        let mut output: Vec<String> = (0..=max_y).map(|_| (0..=max_x).map(|_| '.').collect::<String>()).collect();

        for (x, y) in p2 {
            output[y].replace_range(x..=x, "#");
        }

        return (p1.to_string(), output.join("\n"))
    }
}

fn fold(points: Vec<(usize, usize)>, fold: &Fold) -> Vec<(usize, usize)> {
    match fold {
        Fold::AlongX(fold_x) => {
            return points.iter()
                .filter(|(x, _)| x != fold_x)
                .map(|(x, y)| if x < fold_x { (*x, *y) } else { (fold_x - (x - fold_x), *y) })
                .collect();
        },
        Fold::AlongY(fold_y) => {
            return points.iter()
                .filter(|(_, y)| y != fold_y)
                .map(|(x, y)| if y < fold_y { (*x, *y) } else { (*x, fold_y - (y - fold_y)) })
                .collect();
        }
    }
}

fn parse_points(ps: &str) -> Vec<(usize, usize)> {
    return ps.lines()
        .map(|line| {
            let mut split_line = line.split(",");
            return (
                split_line.next().unwrap().parse().unwrap(),
                split_line.next().unwrap().parse().unwrap()
            )
        })
        .collect();
}

fn parse_folds(ps: &str) -> Vec<Fold> {
    return ps.lines()
        .map(|line| return match line.as_bytes()[11] {
            b'x' => Fold::AlongX(line[13..].parse().unwrap()),
            b'y' => Fold::AlongY(line[13..].parse().unwrap()),
            _ => panic!("unknown fold")
        })
        .collect();
}
