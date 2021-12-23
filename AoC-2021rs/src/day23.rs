use std::collections::BinaryHeap;

use hashbrown::HashMap;

use crate::aoc::AocSolution;

#[derive(Clone, PartialEq, Eq)]
struct State {
    hallway: [u8; 7],
    rooms: [Vec<u8>; 4],
    cost: u64
}

impl Ord for State {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        other.cost.cmp(&self.cost)
    }
}

impl PartialOrd for State {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
       Some(self.cmp(other))
    }
}

pub struct Day23;

impl AocSolution for Day23 {

    fn data_path(&self) -> &str { "data/day23.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let initial_state = parse(input);

        let p1 = simulate(&initial_state);

        let mut p2_initial_state = initial_state.clone();
        p2_initial_state.rooms[0].insert(1, b'D');
        p2_initial_state.rooms[0].insert(2, b'D');
        p2_initial_state.rooms[1].insert(1, b'C');
        p2_initial_state.rooms[1].insert(2, b'B');
        p2_initial_state.rooms[2].insert(1, b'B');
        p2_initial_state.rooms[2].insert(2, b'A');
        p2_initial_state.rooms[3].insert(1, b'A');
        p2_initial_state.rooms[3].insert(2, b'C');

        let p2 = simulate(&p2_initial_state);

        return (p1.to_string(), p2.to_string())
    }
}

fn simulate(initial_state: &State) -> u64 {
    let mut binheap: BinaryHeap<State> = BinaryHeap::new();
    binheap.push(initial_state.clone());

    let mut seen = HashMap::new();

    while let Some(state) = binheap.pop() {
        if finished(&state) {
            return state.cost;
        }

        let next_states = next_states(&state);
        for next_state in next_states {
            match seen.get(&(next_state.hallway, hash(&next_state.rooms))) {
                None => {
                    seen.insert((next_state.hallway, hash(&next_state.rooms)), next_state.cost);
                    binheap.push(next_state);
                },
                Some(value) => {
                    if *value > next_state.cost {
                        seen.insert((next_state.hallway, hash(&next_state.rooms)), next_state.cost);
                        binheap.push(next_state);
                    }
                }
            }

        };
    }

    panic!("No solution found!");
}

fn hash(rooms: &[Vec<u8>; 4]) -> [u64; 4] {
    return [
        rooms[0].iter().enumerate().map(|(i, v)| (*v as u64) << i).sum::<u64>(),
        rooms[1].iter().enumerate().map(|(i, v)| (*v as u64) << i).sum::<u64>(),
        rooms[2].iter().enumerate().map(|(i, v)| (*v as u64) << i).sum::<u64>(),
        rooms[3].iter().enumerate().map(|(i, v)| (*v as u64) << i).sum::<u64>()
    ];
}

fn next_states(state: &State) -> Vec<State> {
    let mut result: Vec<State> = vec![];

    for room in 0..4 as usize {
        for room_i in 0..state.rooms[room].len() - 1 {
            if state.rooms[room][room_i] == 0 && state.rooms[room][room_i + 1] != 0 && (room_i + 1..state.rooms[room].len()).any(|i| state.rooms[room][i] != 0 && amphipod_target_room(state.rooms[room][i]) != room) {
                // Move from back to front of room
                let mut new_state = state.clone();
                new_state.rooms[room][room_i] = new_state.rooms[room][room_i + 1];
                new_state.rooms[room][room_i + 1] = 0;
                new_state.cost += cost(new_state.rooms[room][room_i]);
                result.push(new_state);
            }

            if state.rooms[room][room_i] != 0 && state.rooms[room][room_i + 1] == 0 && amphipod_target_room(state.rooms[room][room_i]) == room {
                // Move from front to back of room
                let mut new_state = state.clone();
                new_state.rooms[room][room_i + 1] = new_state.rooms[room][room_i];
                new_state.rooms[room][room_i] = 0;
                new_state.cost += cost(new_state.rooms[room][room_i + 1]);
                result.push(new_state);
            }
        }

        if state.rooms[room][0] != 0 && (amphipod_target_room(state.rooms[room][0]) != room || state.rooms[room].iter().any(|amphipod| *amphipod != 0 && amphipod_target_room(*amphipod) != room)) {
            // Move out of room into hallway
            let (hallway_left, hallway_right) = hallway_spots_from_room(room);
            for hallway_position in (0..=hallway_left).rev() {
                if state.hallway[hallway_position] != 0 {
                    break;
                }

                let mut new_state = state.clone();
                new_state.hallway[hallway_position] = state.rooms[room][0];
                new_state.rooms[room][0] = 0;
                let steps_in_hallway = steps_room_to_hallway(room, hallway_position);
                new_state.cost += cost(new_state.hallway[hallway_position]) * (2 + steps_in_hallway) as u64;
                result.push(new_state);
            }
            for hallway_position in hallway_right..7 {
                if state.hallway[hallway_position] != 0 {
                    break;
                }

                let mut new_state = state.clone();
                new_state.hallway[hallway_position] = state.rooms[room][0];
                new_state.rooms[room][0] = 0;
                let steps_in_hallway = steps_room_to_hallway(room, hallway_position);
                new_state.cost += cost(new_state.hallway[hallway_position]) * (2 + steps_in_hallway) as u64;
                result.push(new_state);
            }
        }
    }

    for hallway_position in 0..7 as usize {
        let amphipod = state.hallway[hallway_position];
        if amphipod == 0 { continue; }

        let target_room = amphipod_target_room(amphipod);
        if can_move_to_room_from(target_room, hallway_position, state) {
            let mut new_state = state.clone();
            new_state.rooms[target_room][0] = new_state.hallway[hallway_position];
            new_state.hallway[hallway_position] = 0;
            let steps_in_hallway = steps_room_to_hallway(target_room, hallway_position);
            new_state.cost += cost(new_state.rooms[target_room][0]) * (2 + steps_in_hallway) as u64;
            result.push(new_state);
        }
    }

    return result;
}

fn steps_room_to_hallway(room: usize, hallway_pos: usize) -> usize {
    let (hallway_left, hallway_right) = hallway_spots_from_room(room);
    if hallway_pos <= hallway_left {
        return 2 * (hallway_left - hallway_pos) - if hallway_pos == 0 { 1 } else { 0 };
    } else {
        return 2 * (hallway_pos - hallway_right) - if hallway_pos == 6 { 1 } else { 0 };
    }
}

fn can_move_to_room_from(target_room: usize, hallway_pos: usize, state: &State) -> bool {
    let (room_left, room_right) = hallway_spots_from_room(target_room);
    if hallway_pos <= room_left {
        // Coming from the left
        return can_move_to_room(target_room, state) && ((hallway_pos + 1)..=room_left).all(|pos| state.hallway[pos] == 0);
    } else {
        // Coming from the right
        return can_move_to_room(target_room, state) && (room_right..hallway_pos).all(|pos| state.hallway[pos] == 0);
    }
}

fn can_move_to_room(target_room: usize, state: &State) -> bool {
    state.rooms[target_room][0] == 0 && state.rooms[target_room].iter().all(|amphipod| *amphipod == 0 || (amphipod_target_room(*amphipod) == target_room))
}

fn finished(state: &State) -> bool {
    state.rooms[0].iter().all(|b| *b == b'A')
    &&state.rooms[1].iter().all(|b| *b == b'B')
    &&state.rooms[2].iter().all(|b| *b == b'C')
    &&state.rooms[3].iter().all(|b| *b == b'D')
}

fn amphipod_target_room(amphipod: u8) -> usize {
    match amphipod {
        b'A' => 0,
        b'B' => 1,
        b'C' => 2,
        b'D' => 3,
        _ => panic!("unknown amphipod")
    }
}

fn hallway_spots_from_room(room: usize) -> (usize, usize) {
    (room + 1, room + 2)
}

fn cost(amphipod: u8) -> u64 {
    match amphipod {
        b'A' => 1,
        b'B' => 10,
        b'C' => 100,
        b'D' => 1000,
        _ => panic!("unknown amphipod")
    }
}

fn parse(input: &String) -> State {
    let mut lines = input.lines();
    lines.next();
    lines.next();

    let line3 = lines.next().unwrap().as_bytes();
    let line4 = lines.next().unwrap().as_bytes();

    return State {
        hallway: [0; 7],
        rooms: [
            vec![line3[3], line4[3]],
            vec![line3[5], line4[5]],
            vec![line3[7], line4[7]],
            vec![line3[9], line4[9]],
        ],
        cost: 0
    }
}
