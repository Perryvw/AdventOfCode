#include "aoc.h"
#include "helpers.h"

#include <array>
#include <sstream>

namespace
{
	constexpr auto SCREEN_WIDTH = 40;
	constexpr auto SCREEN_HEIGHT = 6;
	constexpr auto NUM_PIXELS = SCREEN_WIDTH * SCREEN_HEIGHT;
}

AOC_DAY(10)(const std::string& input)
{
	auto x = 1;
	auto cycles = 0;

	long p1 = 0;

	std::array<bool, NUM_PIXELS> display{};

	auto incrementCycle = [&] {
		auto pixel = cycles % NUM_PIXELS;
		auto dist = x - (pixel % SCREEN_WIDTH);
		if (dist >= -1 && dist <= 1)
		{
			display[pixel] = true;
		}

		cycles++;
		if ((cycles - 20) % 40 == 0)
		{
			p1 += (x * cycles);
		}
	};

	ForEachLine(input, [&](std::string_view line) {
		if (line[0] == 'n')
		{
			incrementCycle();
		}

		if (line[0] == 'a')
		{
			auto num = parseInt(line.substr(4));
			incrementCycle();
			incrementCycle();
			x += num;
		}
	});

	std::stringstream p2;
	p2 << std::endl;
	for (auto y = 0; y < SCREEN_HEIGHT; ++y)
	{
		for (auto x = 0; x < SCREEN_WIDTH; ++x)
		{
			p2 << (display[y * SCREEN_WIDTH + x] ? '#' : ' ');
		}
		p2 << std::endl;
	}

	return { p1, p2.str() };
}