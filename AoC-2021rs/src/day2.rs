use crate::aoc::AocSolution;

pub struct Day2;

struct Position {
    x: i32,
    y: i32
}

impl Position {
    fn origin() -> Position { Position{ x: 0, y: 0 }}
}

struct PositionWithAim {
    x: i32,
    y: i32,
    aim: i32
}

impl PositionWithAim {
    fn origin() -> PositionWithAim { PositionWithAim{ x: 0, y: 0, aim: 0 }}
}

impl AocSolution for Day2 {

    fn data_path(&self) -> &str { "data/day2.txt" }

    fn calculate(&self, input: &String) -> (String, String) {
        let instructions: Vec<Position> = input.lines().map(parse_instruction).collect();

        let p1: Position = instructions.iter()
            .fold(Position::origin(),
            |current, instruction| Position{
                 x: current.x + instruction.x,
                 y: current.y + instruction.y
            });

        let p2: PositionWithAim = instructions.iter()
            .fold(PositionWithAim::origin(),
            |current, instruction| PositionWithAim{
                x: current.x + instruction.x,
                y: current.y + instruction.x * current.aim,
                aim: current.aim + instruction.y
            });

        return ((p1.x * p1.y).to_string(), (p2.x * p2.y).to_string());
    }
}

fn parse_instruction(value: &str) -> Position {
    let mut split =  value.split_whitespace();
    return match split.next() {
        Some("forward") => Position{ x: split.next().unwrap().parse().unwrap(), y: 0 },
        Some("down") => Position{ x: 0, y: split.next().unwrap().parse().unwrap() },
        Some("up") => Position{ x: 0, y: -split.next().unwrap().parse::<i32>().unwrap() },
        _ => panic!("unknown instruction"),
    }
}