#include "aoc.h"

#include <array>
#include <charconv>
#include <sstream>
#include <vector>

namespace
{
	std::pair<std::pair<int, int>, std::pair<int, int>> parsePair(const std::string_view& s)
	{
		auto comma = s.find(',');
		auto firstMin = s.find('-');
		auto secondMin = s.find('-', comma);

		int a{};
		int b{};
		int c{};
		int d{};

		std::from_chars(s.data(), s.data() + firstMin, a);
		std::from_chars(s.data() + firstMin + 1, s.data() + comma, b);
		std::from_chars(s.data() + comma + 1, s.data() + secondMin, c);
		std::from_chars(s.data() + secondMin + 1, s.data() + s.length(), d);

		return { { a, b }, { c, d } };
	}
}

AOC_DAY(4)(const std::string& input)
{
	size_t p1 = 0;
	size_t p2 = 0;

	ForEachLine(input, [&](auto line) {
		auto [elf1, elf2] = parsePair(line);

		if ((elf1.first >= elf2.first && elf1.second <= elf2.second) || (elf2.first >= elf1.first && elf2.second <= elf1.second))
		{
			p1++;
		}

		if ((elf1.first <= elf2.second && elf1.second >= elf2.first) || (elf2.first <= elf1.second && elf2.second >= elf1.first))
		{
			p2++;
		}
	});

	return { p1, p2 };
}