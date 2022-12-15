#include "aoc.h"
#include "helpers.h"

#include <array>
#include <unordered_set>

namespace
{
	constexpr auto NUM_KNOTS = 10;

	inline int sign(int v) { return v == 0 ? 0 : v > 0 ? 1 : -1; }

	long hash(int x, int y) { return x * 100000 + y; }
}

AOC_DAY(9)(const std::string& input)
{
	std::array<int, NUM_KNOTS> knotX{};
	std::array<int, NUM_KNOTS> knotY{};

	std::unordered_set<long> seen{};
	std::unordered_set<long> seen2{};

	ForEachLine(input, [&](std::string_view line) {
		auto num = std::stoi(line.data() + 2);

		for (auto i = 0; i < num; i++)
		{
			if (line[0] == 'U')
				++knotY[0];
			else if (line[0] == 'D')
				--knotY[0];
			else if (line[0] == 'L')
				--knotX[0];
			else if (line[0] == 'R')
				++knotX[0];

			for (auto knot = 1; knot < NUM_KNOTS; ++knot)
			{
				auto dx = knotX[knot - 1] - knotX[knot];
				auto dy = knotY[knot - 1] - knotY[knot];

				if (dx > 1 || dx < -1 || dy > 1 || dy < -1)
				{
					knotX[knot] += sign(dx);
					knotY[knot] += sign(dy);
				}
			}
			seen.insert(hash(knotX[1], knotY[1]));
			seen2.insert(hash(knotX[NUM_KNOTS - 1], knotY[NUM_KNOTS - 1]));
		}
	});

	return { seen.size(), seen2.size() };
}