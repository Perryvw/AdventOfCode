use crate::aoc::AocSolution;

pub struct Day10;

enum ParseResult {
    Incomplete(Vec<u8>),
    Corrupt(u8)
}

const PAREN_L: u8 = '(' as u8;
const PAREN_R: u8 = ')' as u8;
const SQBRACK_L: u8 = '[' as u8;
const SQBRACK_R: u8 = ']' as u8;
const BRACK_L: u8 = '{' as u8;
const BRACK_R: u8 = '}' as u8;
const LT: u8 = '<' as u8;
const GT: u8 = '>' as u8;

impl AocSolution for Day10 {

    fn data_path(&self) -> &str { "data/day10.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let parsed_lines: Vec<ParseResult> = input.lines().map(parse_line).collect();

        let p1: u32 = parsed_lines.iter()
            .map(|result| match result {
                ParseResult::Corrupt(c) => score(&c),
                _ => 0
            })
            .sum();

        let mut autocomplete_scores: Vec<u64> = parsed_lines.iter()
            .map(|result| match result {
                ParseResult::Incomplete(stack) => stack_score(stack),
                _ => 0
            })
            .filter(|s| *s > 0)
            .collect();

        autocomplete_scores.sort();

        let p2 = autocomplete_scores[autocomplete_scores.len() / 2];

        return (p1.to_string(), p2.to_string())
    }
}

fn parse_line(line: &str) -> ParseResult {
    let mut stack: Vec<u8> = vec![];

    for c in line.as_bytes() {
        match *c {
            PAREN_L => { stack.push(PAREN_R) },
            SQBRACK_L => { stack.push(SQBRACK_R) },
            BRACK_L => { stack.push(BRACK_R) },
            LT => { stack.push(GT) },
            other => if stack.pop().unwrap() != other {
                return ParseResult::Corrupt(other)
            }
        }
    }

    return ParseResult::Incomplete(stack);
}

fn score(c: &u8) -> u32 {
    return match *c {
        PAREN_R => 3,
        SQBRACK_R => 57,
        BRACK_R => 1197,
        GT => 25137,
        _ => panic!("unexpected illegal character {}", *c as char)
    }
}

fn stack_score(stack: &Vec<u8>) -> u64 {
    let mut score: u64 = 0;
    for c in stack.iter().rev() {
        score *= 5;
        score += match *c {
            PAREN_R => 1,
            SQBRACK_R => 2,
            BRACK_R => 3,
            GT => 4,
            _ => panic!("unexpected autocomplete character {}", *c as char)
        }
    }
    return score;
}
