use crate::aoc::AocSolution;

pub struct Day8;

struct Line<'a> {
    input: Vec<&'a str>,
    output: Vec<&'a str>,
}

type DigitKey = [bool; 7];
struct Key {
    key1: DigitKey,
    key4: DigitKey,
}

impl AocSolution for Day8 {

    fn data_path(&self) -> &str { "data/day8.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let lines: Vec<Line> = input.lines().map(|l| parse_line(l)).collect();

        let p1: usize = lines.iter()
            .map(|l| l.output.iter()
                .filter(|word| is1(word) || is4(word) || is7(word) || is8(word))
                .count()
            ).sum();

        let p2: u64 = lines.iter().map(|l| decode_output(l)).sum();

        return (p1.to_string(), p2.to_string())
    }
}

fn is1(w: &str) -> bool { w.len() == 2 }
fn is4(w: &str) -> bool { w.len() == 4 }
fn is7(w: &str) -> bool { w.len() == 3 }
fn is8(w: &str) -> bool { w.len() == 7 }

fn decode_output(l: &Line) -> u64 {
    let key = find_key(&l.input);

    return l.output.iter()
        .rev()
        .enumerate()
        .map(|(i, digit)| (detect_digit(digit, &key) * u32::pow(10, i as u32)) as u64)
        .sum();
}

fn detect_digit(word: &str, key: &Key) -> u32 {
    if is1(word) { return 1 }
    if is4(word) { return 4 }
    if is7(word) { return 7 }
    if is8(word) { return 8 }

    let word_key = word_to_key(word);

    match (word.len(), overlap(&word_key, &key.key1), overlap(&word_key, &key.key4)) {
        (6, 2, 3) => 0,
        (5, 1, 2) => 2,
        (5, 2, 3) => 3,
        (5, 1, 3) => 5,
        (6, 1, 3) => 6,
        (6, 2, 4) => 9,
        _ => panic!("{}, {}, {}, {}", word, word.len(), overlap(&word_key, &key.key1), overlap(&word_key, &key.key4))
    }
}

fn find_key(input: &Vec<&str>) -> Key {
    let mut key1: Option<DigitKey> = None;
    let mut key4: Option<DigitKey> = None;

    for word in input {
        if is1(word) { key1 = Some(word_to_key(word)) }
        else if is4(word) { key4 = Some(word_to_key(word)) }
    }

    return Key{ key1: key1.unwrap(), key4: key4.unwrap() };
}

fn word_to_key(word: &str) -> DigitKey {
    let mut key = [false; 7];
    for c in word.as_bytes() {
        key[(c - 'a' as u8) as usize] = true;
    }
    return key;
}

fn overlap(word: &DigitKey, key: &DigitKey) -> usize {
    return word.iter().enumerate().filter(|(i, v)| **v && key[*i]).count();
}

fn parse_line(line: &str) -> Line {
    let split_input: Vec<&str> = line.split("|").collect();
    let input_nums: Vec<&str> = split_input[0].split_whitespace().collect();
    let output_nums: Vec<&str> = split_input[1].split_whitespace().collect();
    return Line { input: input_nums, output: output_nums };
}
