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

        let mut p1 = 0;
        let mut autocomplete_scores: Vec<u64> = vec![];

        for parse_result in input.lines().map(parse_line) {
            match parse_result {
                ParseResult::Corrupt(c) => {
                    p1 += score(&c)
                },
                ParseResult::Incomplete(stack) => {
                    let score = stack_score(&stack);
                    if score > 0 { autocomplete_scores.push(score) }
                },
            }
        }

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
