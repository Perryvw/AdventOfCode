// use std::fs::File;
// use std::io::{self, BufRead};
// use regex::Regex;

// pub fn read_lines(file_name: &str) -> impl std::iter::Iterator<Item=std::string::String> {
//     let file = File::open(file_name).unwrap();
//     return io::BufReader::new(file).lines().map(|l| l.unwrap());
// }

// pub fn parse_lines(file_name: &str, pattern: &str) -> impl std::iter::Iterator<Item=Vec<String>> {
//     return read_lines(file_name)
//         .map(move |l| {
//             let captures = re.captures(&l).unwrap();
//             let t = (1..captures.len()).map(|i| String::from(captures.get(i).unwrap().as_str())).collect();
//             return t;
//         });
// }