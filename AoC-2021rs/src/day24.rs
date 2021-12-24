use std::collections::VecDeque;

use hashbrown::HashMap;

use crate::aoc::AocSolution;

pub struct Day24;

impl AocSolution for Day24 {

    fn data_path(&self) -> &str { "data/day24.txt" }

    fn calculate(&self, input: &String) -> (String, String) {

        let blocks: Vec<Vec<&str>> = input.split("inp w").skip(1).map(|block| block.trim().lines().collect()).collect();

        // Print out z3 model to output
        for (i, _) in blocks.iter().enumerate() {
            println!("(declare-const x{} Int)", i);
            println!("(declare-const inp{} Int)", i);
            println!("(declare-const z{} Int)", i);
        }
        println!("(declare-const z{} Int)", blocks.len());
        println!();

        // First and last z values have to be 0
        println!("(assert (= z0 0))");
        println!("(assert (= z{} 0))", blocks.len());
        println!();

        for (i, block) in blocks.iter().enumerate() {
            //println!("parsing {}, {}, {}", block[2][6..].to_owned(), block[3][6..].to_owned(), block[4][6..].to_owned());
            let var1: i64 = block[2][6..].parse().unwrap();
            let var2: i64 = block[3][6..].parse().unwrap();
            let var3: i64 = block[4][6..].parse().unwrap();
            println!("(assert (= x{} (ite (not (= (+ (mod z{} {}) {}) inp{})) 1 0)))", i, i, var1, var3, i);
            let var4: i64 = block[8][6..].parse().unwrap();
            let var5: i64 = block[14][6..].parse().unwrap();
            println!("(assert (= z{} (+ (* (div z{} {}) (+ (* {} x{}) 1) ) (* x{} (+ inp{} {}) ) ) ) )", i + 1, i, var2, var4, i, i, i, var5);
        }

        for (i, _) in blocks.iter().enumerate() {
            println!("(assert (> inp{} 0))", i);
        }

        for (i, _) in blocks.iter().enumerate() {
            println!("(assert (<= inp{} 9))", i);
        }

        println!("(check-sat)");
        println!("(echo \"------------------------------------------\")");
        println!("(echo \"Model: \")");
        println!("(get-value (inp0 inp1 inp2 inp3 inp4 inp5 inp6 inp7 inp8 inp9 inp10 inp11 inp12 inp13))");

        let instructions: Vec<Instruction> = input.lines().map(parse_instruction).collect();

        let mut state = ProgramState { instruction_pointer: 0, registers: HashMap::new() };

        let mut input = VecDeque::new();
        input.push_back(9);
        input.push_back(9);
        input.push_back(7);
        input.push_back(9);
        input.push_back(9);
        input.push_back(2);
        input.push_back(1);
        input.push_back(2);
        input.push_back(9);
        input.push_back(4);
        input.push_back(9);
        input.push_back(9);
        input.push_back(6);
        input.push_back(7);

        while state.instruction_pointer < instructions.len() {
            state = update(&state, &instructions, &mut input);
        }

        return (String::from("?"), String::from("?"))
    }
}

enum Instruction {
    Inp(char),
    Add(char, char),
    AddNum(char, i64),
    Mul(char, char),
    MulNum(char, i64),
    Div(char, char),
    DivNum(char, i64),
    Mod(char, char),
    ModNum(char, i64),
    Eql(char, char),
    EqlNum(char, i64),
}

struct ProgramState {
    instruction_pointer: usize,
    registers: HashMap<char, i64>
}

fn update(state: &ProgramState, instructions: &Vec<Instruction>, input: &mut VecDeque<i64>) -> ProgramState {
    let mut new_registers = state.registers.clone();

    match instructions[state.instruction_pointer] {
        Instruction::Inp(v) => { new_registers.insert(v, input.pop_front().unwrap()); },
        Instruction::Add(a, b) => {
            *new_registers.entry(a).or_insert(0) += *new_registers.entry(b).or_insert(0)
        },
        Instruction::AddNum(a, b) => {
            *new_registers.entry(a).or_insert(0) += b
        },
        Instruction::Mul(a, b) => {
            *new_registers.entry(a).or_insert(0) *= *new_registers.entry(b).or_insert(0)
        },
        Instruction::MulNum(a, b) => {
            *new_registers.entry(a).or_insert(0) *= b
        },
        Instruction::Div(a, b) => {
            *new_registers.entry(a).or_insert(0) /= *new_registers.entry(b).or_insert(0)
        },
        Instruction::DivNum(a, b) => {
            *new_registers.entry(a).or_insert(0) /= b
        },
        Instruction::Mod(a, b) => {
            *new_registers.entry(a).or_insert(0) %= *new_registers.entry(b).or_insert(0)
        },
        Instruction::ModNum(a, b) => {
            *new_registers.entry(a).or_insert(0) %= b
        },
        Instruction::Eql(a, b) => {
            *new_registers.entry(a).or_insert(0) = if new_registers.get(&a).unwrap_or(&0) == new_registers.get(&b).unwrap_or(&0) { 1 } else { 0 }
        },
        Instruction::EqlNum(a, b) => {
            *new_registers.entry(a).or_insert(0) = if *new_registers.get(&a).unwrap_or(&0) == b { 1 } else { 0 }
        },
    }

    return ProgramState {
        instruction_pointer: state.instruction_pointer + 1,
        registers: new_registers
    };
}

fn parse_instruction(line: &str) -> Instruction {
    match &line[..3] {
        "inp" => Instruction::Inp(line.chars().nth(4).unwrap()),
        "add" => {
            let var = line.chars().nth(4).unwrap();
            let first_rest = line.chars().nth(6).unwrap();
            if (first_rest >= '0' && first_rest <= '9') || first_rest == '-' {
                Instruction::AddNum(var, line[6..].parse().unwrap())
            } else {
                Instruction::Add(var, first_rest)
            }
        }
        "mul" => {
            let var = line.chars().nth(4).unwrap();
            let first_rest = line.chars().nth(6).unwrap();
            if (first_rest >= '0' && first_rest <= '9') || first_rest == '-' {
                Instruction::MulNum(var, line[6..].parse().unwrap())
            } else {
                Instruction::Mul(var, first_rest)
            }
        }
        "div" => {
            let var = line.chars().nth(4).unwrap();
            let first_rest = line.chars().nth(6).unwrap();
            if (first_rest >= '0' && first_rest <= '9') || first_rest == '-' {
                Instruction::DivNum(var, line[6..].parse().unwrap())
            } else {
                Instruction::Div(var, first_rest)
            }
        }
        "mod" => {
            let var = line.chars().nth(4).unwrap();
            let first_rest = line.chars().nth(6).unwrap();
            if (first_rest >= '0' && first_rest <= '9') || first_rest == '-' {
                Instruction::ModNum(var, line[6..].parse().unwrap())
            } else {
                Instruction::Mod(var, first_rest)
            }
        }
        "eql" => {
            let var = line.chars().nth(4).unwrap();
            let first_rest = line.chars().nth(6).unwrap();
            if (first_rest >= '0' && first_rest <= '9')  || first_rest == '-' {
                Instruction::EqlNum(var, line[6..].parse().unwrap())
            } else {
                Instruction::Eql(var, first_rest)
            }
        }
        _ => panic!("unknown instruction")
    }
}