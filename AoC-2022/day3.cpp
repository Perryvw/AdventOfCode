#include "aoc.h"

#include <array>
#include <sstream>
#include <unordered_set>

namespace {

	auto part1(const std::string& rucksack)
	{
		std::string_view halfString{ rucksack.c_str(), rucksack.length() / 2};
		std::unordered_set<char> items{ halfString.begin(), halfString.end() };

		for (auto i = rucksack.length() / 2; i < rucksack.length(); ++i) {
			if (items.count(rucksack[i]) > 0)
			{
				return rucksack[i];
			}
		}
	}

	auto part2(const std::array<std::string, 3>& rucksacks)
	{
		std::unordered_set<char> elf1{ rucksacks[0].begin(), rucksacks[0].end() };
		std::unordered_set<char> elf2{ rucksacks[1].begin(), rucksacks[1].end() };

		for (auto c : rucksacks[2])
		{
			if (elf1.count(c) > 0 && elf2.count(c) > 0)
			{
				return c;
			}
		}
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