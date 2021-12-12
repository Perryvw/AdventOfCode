use crate::aoc::AocSolution;
use hashbrown::{HashMap, HashSet};

type NodePair<'a> = (&'a str, &'a str);

pub struct Day12;

impl AocSolution for Day12 {

    fn data_path(&self) -> &str { "data/day12.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let mut adj_list = HashMap::<&str, Vec<&str>>::new();
        input.lines().map(parse).for_each(|(from, to)| {
            adj_list.entry(from).or_insert(vec![]).push(to);
            adj_list.entry(to).or_insert(vec![]).push(from);
        });

        let seen = HashSet::<&str>::new();
        let seen2 = HashSet::<&str>::new();

        let p1 = count_paths(vec!["start"], &adj_list, seen, 0);
        let p2 = count_paths(vec!["start"], &adj_list, seen2, 1);

        return (p1.to_string(), p2.to_string());
    }
}

fn count_paths<'a>(current: Vec<&'a str>, adj_list: &'a HashMap<&str, Vec<&str>>, seen: HashSet<&str>, jokers: u8) -> u32 {
    if *current.last().unwrap() == "end" {
        return 1;
    }
    let current_node = current.last().unwrap();
    return adj_list.get(current_node).unwrap().iter()
        .map(|neighbour| {

            let mut new_path = current.clone();
            new_path.push(neighbour);
            let mut new_seen = seen.clone();

            if !is_big_cave(current_node) {
                new_seen.insert(current_node);
            }

            if seen.contains(*neighbour) && is_small_cave(*neighbour) && jokers > 0 {
                return count_paths(new_path, adj_list, new_seen, jokers - 1);
            }

            if seen.contains(*neighbour) {
                return 0;
            }

            return count_paths(new_path, adj_list, new_seen, jokers);
        }).sum();
}

fn is_big_cave(cave: &str) -> bool {
    let first_char = *cave.as_bytes().first().unwrap();
    return first_char >= b'A' && first_char <= b'Z';
}

fn is_small_cave(cave: &str) -> bool {
    let first_char = *cave.as_bytes().first().unwrap();
    return first_char >= b'a' && first_char <= b'z' && !is_start_or_end(cave);
}

fn is_start_or_end(cave: &str) -> bool {
    return cave == "start" || cave == "end";
}

fn parse(line: &str) -> NodePair {
    let i = line.find('-').unwrap();
    return (&line[..i], &line[(i + 1)..]);
}
