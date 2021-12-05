use crate::aoc::AocSolution;
use crate::common::{Point, LineSegment};

pub struct Day5;

impl AocSolution for Day5 {

    fn data_path(&self) -> &str { "data/day5.txt" }

    fn calculate(&self, input: &String) -> (String, String) {
        let vents: Vec<LineSegment> = input.lines().map(parse).collect();

        // P1
        let mut map = [0 as i8; 1000000];
        for vent in vents.iter().filter(|s| is_horizontal_or_vertical(s)) {
            for point in points(vent) {
                map[hash(&point)] += 1;
            }
        }
        let num_dangerous_points = map.iter().filter(|v| **v >= 2).count();

        // P2
        for vent in vents.iter().filter(|s| !is_horizontal_or_vertical(s)) {
            for point in points(vent) {
                map[hash(&point)] += 1;
            }
        }
        let num_dangerous_points_all = map.iter().filter(|v| **v >= 2).count();

        return (num_dangerous_points.to_string(), num_dangerous_points_all.to_string());
    }
}

fn hash(point: &Point) -> usize {
    return (point.x * 1000 + point.y) as usize;
}

fn is_horizontal_or_vertical(seg: &LineSegment) -> bool {
    return seg.from.x == seg.to.x || seg.from.y == seg.to.y;
}

fn points(seg: &LineSegment) -> impl Iterator<Item=Point> {
    let stepx = if seg.from.x == seg.to.x { 0 } else if seg.from.x < seg.to.x { 1 } else { -1 };
    let stepy = if seg.from.y == seg.to.y { 0 } else if seg.from.y < seg.to.y { 1 } else { -1 };
    let steps = std::cmp::max((seg.from.x - seg.to.x).abs(), (seg.from.y - seg.to.y).abs()) + 1;
    let startx = seg.from.x;
    let starty = seg.from.y;

    return (0..steps).map(move |i| Point { x: startx + stepx * i, y: starty + stepy * i });
}

fn parse(line: &str) -> LineSegment {
    let mut split = line.split(" -> ");
    return LineSegment {
        from: parse_point(split.next().unwrap()),
        to: parse_point(split.next().unwrap())
    };
}

fn parse_point(pstr: &str) -> Point {
    let mut split = pstr.split(",");
    return Point {
        x: split.next().unwrap().parse().unwrap(),
        y: split.next().unwrap().parse().unwrap(),
    };
}
