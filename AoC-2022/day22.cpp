#include "aoc.h"
#include "helpers.h"

#include <variant>
#include <vector>

namespace
{
	enum Direction
	{
		Right,
		Down,
		Left,
		Up
	};

	struct Row {
		size_t offset;
		size_t width;
		std::string str;
	};

	using Instruction = std::variant<int, char>;
	using Board = std::vector<Row>;

	bool canWalkAt(int x, int y, const Board& board)
	{
		return y >= 0 && y < board.size() && x >= board[y].offset && x < board[y].offset + board[y].width;
	}

	bool isWallAt(int x, int y, const Board& board) { return board[y].str[x - board[y].offset] == '#'; }

	bool wrapP1(int& x, int& y, Direction& direction, const Board& board)
	{
		auto nx = x;
		auto ny = y;
		if (direction == Direction::Right)
		{
			nx = board[y].offset;
		}
		else if (direction == Direction::Left)
		{
			nx = board[y].offset + board[y].width - 1;
		}
		else if (direction == Direction::Down)
		{
			ny = 0;
			while (!canWalkAt(x, ny, board))
				ny++;
		}
		else if (direction == Direction::Up)
		{
			ny = board.size() - 1;
			while (!canWalkAt(x, ny, board))
				ny--;
		}

		if (!isWallAt(nx, ny, board))
		{
			x = nx;
			y = ny;
			return true;
		}
		else
		{
			return false;
		}
	}

	int rectangle(int x, int y)
	{
		if (y < 50)
		{
			if (x < 100)
				return 2;
			else
				return 1;
		}
		else if (y < 100)
			return 3;
		else if (y < 150)
		{
			if (x < 50)
				return 5;
			else
				return 4;
		}
		else
			return 6;
	}

	std::pair<int, int> deltaMovement(Direction direction)
	{
		switch (direction)
		{
		case Direction::Right:
			return { 1, 0 };
		case Direction::Down:
			return { 0, 1 };
		case Direction::Left:
			return { -1, 0 };
		case Direction::Up:
			return { 0, -1 };
		}
	}

	bool wrapP2(int& x, int& y, Direction& direction, const Board& board)
	{
		auto currentRect = rectangle(x, y);
		auto nx = x;
		auto ny = y;
		auto nd = direction;

		if (currentRect == 1)
		{
			if (direction == Direction::Up)
			{
				nx = x - 100;
				ny = 199;
				nd = Direction::Up;
			}
			else if (direction == Direction::Right)
			{
				nx = 99;
				ny = 149 - y;
				nd = Direction::Left;
			}
			else if (direction == Direction::Down)
			{
				nx = 99;
				ny = x - 50;
				nd = Direction::Left;
			}
		}
		else if (currentRect == 2)
		{
			if (direction == Direction::Up)
			{
				nx = 0;
				ny = x + 100;
				nd = Direction::Right;
			}
			else if (direction == Direction::Left)
			{
				nx = 0;
				ny = 149 - y;
				nd = Direction::Right;
			}
		}
		else if (currentRect == 3)
		{
			if (direction == Direction::Left)
			{
				nx = y - 50;
				ny = 100;
				nd = Direction::Down;
			}
			else if (direction == Direction::Right)
			{
				nx = y + 50;
				ny = 49;
				nd = Direction::Up;
			}
		}
		else if (currentRect == 4)
		{
			if (direction == Direction::Right)
			{
				nx = 149;
				ny = 149 - y;
				nd = Direction::Left;
			}
			else if (direction == Direction::Down)
			{
				nx = 49;
				ny = x + 100;
				nd = Direction::Left;
			}
		}
		else if (currentRect == 5)
		{
			if (direction == Direction::Up)
			{
				nx = 50;
				ny = x + 50;
				nd = Direction::Right;
			}
			else if (direction == Direction::Left)
			{
				nx = 50;
				ny = 149 - y;
				nd = Direction::Right;
			}
		}
		else if (currentRect == 6)
		{
			if (direction == Direction::Left)
			{
				nx = y - 100;
				ny = 0;
				nd = Direction::Down;
			}
			else if (direction == Direction::Right)
			{
				nx = y - 100;
				ny = 149;
				nd = Direction::Up;
			}
			else if (direction == Direction::Down)
			{
				nx = x + 100;
				ny = 0;
				nd = Direction::Down;
			}
		}

		auto nextRect = rectangle(nx, ny);
		if (!isWallAt(nx, ny, board))
		{
			x = nx;
			y = ny;
			direction = nd;
			return true;
		}
		else
		{
			return false;
		}
	}

	template <typename TWrap> void move(int& x, int& y, Direction& direction, int distance, const Board& board, const TWrap& wrap)
	{
		auto [dx, dy] = deltaMovement(direction);

		for (auto step = 0; step < distance; ++step)
		{
			if (!canWalkAt(x + dx, y + dy, board))
			{
				if (!wrap(x, y, direction, board))
				{
					return;
				}

				auto newDelta = deltaMovement(direction);
				dx = newDelta.first;
				dy = newDelta.second;
			}
			else if (isWallAt(x + dx, y + dy, board))
			{
				return;
			}
			else
			{
				x += dx;
				y += dy;
			}
		}
	}

	template <typename TWrap> size_t solve(const Board& board, const std::vector<Instruction>& instructions, const TWrap& wrap)
	{
		auto x = static_cast<int>(board[0].offset);
		auto y = 0;
		auto direction = Direction::Right;

		for (auto& i : instructions)
		{
			if (std::holds_alternative<int>(i))
			{
				move(x, y, direction, std::get<int>(i), board, wrap);
			}
			else if (std::get<char>(i) == 'L')
			{
				direction = static_cast<Direction>(posmod(direction - 1, 4));
			}
			else
			{
				direction = static_cast<Direction>(posmod(direction + 1, 4));
			}
		}

		return static_cast<size_t>(1000) * (y + 1) + 4 * (x + 1) + direction;
	}

	void print(int x, int y, const Board& board)
	{
		for (auto cy = 0; cy < board.size(); cy++)
		{
			for (auto o = 0; o < board[cy].offset; o++)
			{
				std::cout << ' ';
			}
			for (auto cx = 0; cx < board[cy].width; cx++)
			{
				if (y == cy && x == board[cy].offset + cx)
				{
					std::cout << 'X';
				}
				else
				{
					std::cout << board[cy].str[cx];
				}
			}
			std::cout << std::endl;
		}
		std::cout << std::endl;
	}
}

FOCUS_AOC_DAY(22)(const std::string& input)
{
	std::vector<Row> board;
	std::vector<Instruction> instructions;

	ForEachLine(input, [&](std::string_view line) {
		if (line.empty())
			return;
		if (std::isalnum(line[0]))
		{
			char* linePtr;
			instructions.emplace_back(strtol(line.data(), &linePtr, 10));
			while (linePtr < line.data() + line.size())
			{
				if (std::isdigit(*linePtr))
				{
					instructions.emplace_back(strtol(linePtr, &linePtr, 10));
				}
				else
				{
					instructions.emplace_back(*linePtr);
					linePtr++;
				}
			}
		}
		else
		{
			size_t i = 0;
			while (line[i] == ' ')
				i++;
			auto offset = i;
			board.emplace_back(Row{ offset, line.size() - offset, std::string{ line.substr(offset) } });
		}
	});

	auto p1 = solve(board, instructions, wrapP1);
	auto p2 = solve(board, instructions, wrapP2);

	return { p1, p2 };
}