#include "aoc.h"
#include <optional>

using Board = uint64_t;

inline int boardBit(int x, int y) {
	return x * 8 + y;
}

inline bool occupied(Board board, int x, int  y) {
	return ((board >> boardBit(x, y)) % 2) == 1;
}

inline Board setBoard(Board board, int x, int y, bool occupied) {
	return occupied
		? (board | 1ll << boardBit(x, y))
		: (board & (-1ll ^ (1ll << boardBit(x, y))));
}

void printSolution(Board board) {
	for (auto y = 0; y < 17; ++y) {
		for (auto x = 0; x < 8; ++x) {
			if (y % 2 == 0) {
				std::cout << "----";
			}
			else {
				std::cout << (occupied(board, x, y/2) ? "| Q " : "|   ");
			}
		}

		std::cout << ((y % 2 == 1) ? "|" : "-");

		std::cout << std::endl;
	}
}

std::optional<Board> findValidSolution(int x, Board currentBoard, Board seenSquares, int& nodes) {
	if (x == 8) {
		return currentBoard;
	}

	++nodes;

	for (auto y = 0; y < 8; ++y) {
		if (!occupied(seenSquares, x, y)) {
			auto newSeenSquares = setBoard(seenSquares, x, y, true);
			for (auto x2 = x + 1; x2 < 8; ++x2) {
				newSeenSquares = setBoard(newSeenSquares, x2, y, true);
				auto dy1 = y - (x2 - x);
				if (dy1 >= 0)
					newSeenSquares = setBoard(newSeenSquares, x2, dy1, true);
				auto dy2 = y + (x2 - x);
				if (dy2 < 8)
					newSeenSquares = setBoard(newSeenSquares, x2, dy2, true);
			}

			auto result = findValidSolution(x + 1, setBoard(currentBoard, x, y, true), newSeenSquares, nodes);
			if (result.has_value()) {
				return result;
			}
		}
	}

	return std::nullopt;
}

class Day1 : public AoC::Answer {
	std::optional<Board> solution;
	int nodes;

	void compute() override {
		nodes = 0;

		solution = findValidSolution(0, 0ll, 0ll, nodes);
	}

	void print() override {
		log("Naive backtracking: ");
		log();

		if (solution.has_value()) {
			printSolution(solution.value());
		}
		else {
			log("No solution found");
		}

		log("Visited ", nodes, " nodes");
	}
};

std::unique_ptr<AoC::Answer> AoC::day1() {
	return std::make_unique<Day1>();
}
