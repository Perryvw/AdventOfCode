use crate::aoc::AocSolution;

const WIDTH: usize = 5;
const HEIGHT: usize = 5;

type BoardCells = [[u16; WIDTH]; HEIGHT];
type BoardMarked = [[bool; WIDTH]; HEIGHT];

struct Board {
    has_won: bool,
    cells: BoardCells,
    marked: BoardMarked,
}

pub struct Day4;

impl AocSolution for Day4 {

    fn data_path(&self) -> &str { "data/day4.txt" }

    fn calculate(&self, input: &String) -> (String, String) {
        let mut split = input.split("\r\n\r\n");
        let nums: Vec<u16> = split.next().unwrap().split(",").map(|n| n.parse().unwrap()).collect();

        let mut boards: Vec<Board> = split.map(parse).collect();

        let mut result: Option<u32> = None;
        let mut last_result: Option<u32> = None;

        for n in nums {
            boards.iter_mut().for_each(|board| mark_number(board, n));

            for winning_board in boards.iter_mut().filter(|board| !board.has_won && has_won(board)) {
                winning_board.has_won = true;

                if result.is_none() {
                    result = Some(sum_unmarked(winning_board) * n as u32);
                }
                winning_board.has_won = true;
                last_result = Some(sum_unmarked(winning_board) * n as u32);
            }
        };

        return (result.unwrap().to_string(), last_result.unwrap().to_string());
    }
}

fn parse(boardstr: &str) -> Board {
    let mut cells: BoardCells = [[0; 5]; 5];

    boardstr.lines()
        .enumerate()
        .for_each(|(y, line)|
            line.split_whitespace()
                .enumerate()
                .for_each(|(x, v)|
                    cells[x][y] = v.parse().unwrap()
                )
        );

    let marked: BoardMarked = [[false; 5]; 5];

    return Board{ has_won: false, cells: cells, marked: marked };
}

fn mark_number(board: &mut Board, num: u16) {
    (0..WIDTH).for_each(|x|
        (0..HEIGHT).for_each(|y|
            if board.cells[x][y] == num {
                board.marked[x][y] = true;
            }
        )
    )
}

fn has_won(board: &Board) -> bool {
    let row_won = board.marked.iter().any(|row| row.iter().all(|v| *v));
    let col_won = (0..WIDTH).any(|col| board.marked.iter().all(|line| line[col]));

    return row_won || col_won;
}

fn sum_unmarked(board: &Board) -> u32 {
    let mut sum: u32 = 0;
    (0..WIDTH).for_each(|x|
        (0..HEIGHT).for_each(|y|
            if !board.marked[x][y] {
                sum += board.cells[x][y] as u32;
            }
        )
    );
    return sum;
}
