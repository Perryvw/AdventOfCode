use hashbrown::HashMap;

use crate::aoc::AocSolution;

pub struct Day21;

impl AocSolution for Day21 {

    fn data_path(&self) -> &str { "data/day3.txt" }

    fn calculate(&self, _: &String) -> (String, String) {

        let mut p1pos = 3 - 1;
        let mut p2pos = 7 - 1;

        let mut p1score = 0;
        let mut p2score = 0;

        let mut rounds = 1;
        p1pos = (p1pos  + 6) % 10;
        p2pos = (p2pos + 15) % 10;

        p1score += p1pos + 1;
        p2score += p2pos + 1;

        let mut rolls = 6;

        while p1score < 1000 {

            p1pos = (p1pos  + 6 + 18 * rounds) % 10;
            p2pos = (p2pos + 15 + 18 * rounds) % 10;

            p1score += p1pos + 1;

            rolls += 3;

            if p1score >= 1000 { break; }

            rolls += 3;
            p2score += p2pos + 1;

            if p2score >= 1000 { break; }

            rounds += 1;
        }

        let p1 = rolls * std::cmp::min(p1score, p2score);

        let (p1wins, p2wins) = num_wins(2, 0,  6, 0);

        let p2 = std::cmp::max(p1wins, p2wins);

        return (p1.to_string(), p2.to_string())
    }
}

const WIN_SCORE: u8 = 21;

lazy_static! {
    static ref DISTRIBUTION: HashMap<u8, u64> = {
        let mut m = HashMap::new();
        m.insert(3, 1); // 3: 1 - 111
        m.insert(4, 3); // 4: 3 - 112,211,121
        m.insert(5, 6); // 5: 6 - 113,131,311,221,122,212
        m.insert(6, 7); // 6: 7 - 123,132,213,231,312,321,222
        m.insert(7, 6);
        m.insert(8, 3);
        m.insert(9, 1);
        m
    } ;
}

fn num_wins(p1pos: u8, p1points: u8, p2pos: u8, p2points: u8) -> (u64, u64) {

    if p1points >= WIN_SCORE { return (1, 0) }

    let mut p1wins = 0;
    let mut p2wins = 0;

    for (increase, count) in DISTRIBUTION.iter() {
        let newpos = (p1pos + increase) % 10;
        let newscore = p1points + (((p1pos + increase) % 10) + 1);
        if newscore >= WIN_SCORE {
            p1wins += count;
            continue;
        }
        let (_p1wins, _p2wins) = num_wins2(newpos, newscore, p2pos, p2points);
        p1wins += _p1wins * count;
        p2wins += _p2wins * count;
    }

    return (p1wins, p2wins);
}

fn num_wins2(p1pos: u8, p1points: u8, p2pos: u8, p2points: u8) -> (u64, u64) {

    if p2points >= WIN_SCORE { return (0, 1) }

    let mut p1wins = 0;
    let mut p2wins = 0;

    for (increase, count) in DISTRIBUTION.iter() {
        let newpos = (p2pos + increase) % 10;
        let newscore = p2points + (((p2pos + increase) % 10) + 1);
        if newscore >= WIN_SCORE {
            p2wins += count;
            continue;
        }
        let (_p1wins, _p2wins) = num_wins(p1pos, p1points, newpos, newscore);
        p1wins += _p1wins * count;
        p2wins += _p2wins * count;
    }
    return (p1wins, p2wins);
}
