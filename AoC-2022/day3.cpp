#include "aoc.h"

#include <array>
#include <sstream>
#include <unordered_set>

namespace {

	uint64_t tomask(std::string_view rucksack)
	{
		uint64_t m{ 0 };

		for (auto& c : rucksack)
		{
			m |= 1ull << (c - 'A');
		}

		return m;
	}

	char frommask(uint64_t mask)
	{
		for (auto i = 0; i < 64; ++i)
		{
			if (mask & (1ull << i))
			{
				return i + 'A';
			}
		}

		throw std::logic_error{ "Bit out of range" };
	}

	auto part1(const std::string& rucksack)
	{
		auto halfLength = rucksack.length() / 2;
		std::string_view halfString{ rucksack.c_str(), halfLength};
		std::string_view secondHalfString{ rucksack.c_str() + halfLength, halfLength};

		return frommask(tomask(halfString) & tomask(secondHalfString));
	}

	auto part2(const std::array<std::string, 3>& rucksacks)
	{
		auto elf1 = tomask(rucksacks[0]);
		auto elf2 = tomask(rucksacks[1]);
		auto elf3 = tomask(rucksacks[2]);

		return frommask(elf1 & elf2 & elf3);
	}

	auto priority(char c)
	{
		return c >= 'a' ? (c - 'a' + 1) : (c - 'A' + 27);
	}
}

AOC_DAY(3)(const std::string& input)
{
	std::stringstream ss{ input };

	uint32_t p1 = 0;
	uint32_t p2 = 0;

	auto i = 0;
	std::array<std::string, 3> group{};

	while (std::getline(ss, group[i % 3]))
	{
		auto commonItem = part1(group[i % 3]);
		p1 += priority(commonItem);

		if (i % 3 == 2)
		{
			p2 += priority(part2(group));
		}

		i++;
	}

	return { p1, p2 };
}