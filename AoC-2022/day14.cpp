#include "aoc.h"
#include "helpers.h"

#include <array>

namespace
{
	constexpr size_t WIDTH = 1000;
	constexpr size_t HEIGHT = 170;

	enum class Cell
	{
		Empty,
		Rock,
		Sand
	};
	using Grid = std::array<std::array<Cell, HEIGHT>, WIDTH>;

	void PrintGrid(const Grid& grid)
	{
		for (auto y = 0; y < HEIGHT; ++y)
		{
			for (auto x = 0; x < WIDTH; ++x)
			{
				if (x > 450)
				{
					std::cout << (grid[x][y] == Cell::Rock ? '#' : grid[x][y] == Cell::Sand ? 'o' : '.');
				}
			}
			std::cout << std::endl;
		}
		std::cout << std::endl;
	}

	bool Simulate(Grid& grid)
	{
		auto sandx = 500;
		auto sandy = 0;

		while (sandy < HEIGHT - 1)
		{
			if (grid[sandx][sandy + 1] == Cell::Empty)
			{
				sandy++;
			}
			else if (grid[sandx - 1][sandy + 1] == Cell::Empty)
			{
				sandx--;
				sandy++;
			}
			else if (grid[sandx + 1][sandy + 1] == Cell::Empty)
			{
				sandx++;
				sandy++;
			}
			else
			{
				grid[sandx][sandy] = Cell::Sand;
				return true;
			}
		}

		return false;
	}

	void Simulate2(Grid& grid, int depth)
	{
		auto sandx = 500;
		auto sandy = 0;

		while (sandy < depth)
		{
			if (grid[sandx][sandy + 1] == Cell::Empty)
			{
				sandy++;
			}
			else if (grid[sandx - 1][sandy + 1] == Cell::Empty)
			{
				sandx--;
				sandy++;
			}
			else if (grid[sandx + 1][sandy + 1] == Cell::Empty)
			{
				sandx++;
				sandy++;
			}
			else
			{
				grid[sandx][sandy] = Cell::Sand;
				return;
			}
		}
		grid[sandx][sandy] = Cell::Sand;
	}
}

AOC_DAY(14)(const std::string& input)
{
	Grid grid{};

	long maxy = 0;

	ForEachLine(input, [&](const std::string_view& line) {
		auto lineStr = line.data();
		auto endPtr = const_cast<char*>(lineStr);

		long x = 0;
		long y = 0;

		for (auto i = 0; endPtr < lineStr + line.size(); ++i)
		{
			auto nx = strtol(endPtr, &endPtr, 10);
			auto ny = strtol(endPtr + 1, &endPtr, 10);

			if (ny > maxy)
			{
				maxy = ny;
			}

			endPtr += 4;

			if (i > 0)
			{
				auto minx = std::min(x, nx);
				auto maxx = std::max(x, nx);
				auto miny = std::min(y, ny);
				auto maxy = std::max(y, ny);

				for (auto rx = minx; rx <= maxx; ++rx)
				{
					for (auto ry = miny; ry <= maxy; ++ry)
					{
						grid[rx][ry] = Cell::Rock;
					}
				}
			}

			x = nx;
			y = ny;
		}
	});

	auto gridP1 = std::make_unique<Grid>(grid);
	auto p1 = 0;

	while (Simulate(*gridP1))
	{
		p1++;
	}

	auto gridP2 = std::make_unique<Grid>(grid);
	auto p2 = 0;

	while ((*gridP2)[500][0] == Cell::Empty)
	{
		p2++;
		Simulate2(*gridP2, maxy + 1);
	}

	return { p1, p2 };
}