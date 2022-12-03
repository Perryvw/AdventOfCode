#include "aoc.h"

#include <array>
#include <sstream>
#include <vector>

namespace {
	size_t part1(const std::vector<uint32_t>& elves)
	{
		return *std::max_element(elves.begin(), elves.end());
	}

	void insertOrdered(std::array<uint32_t, 3>& arr, uint32_t val)
	{
		if (val > arr[0])
		{
			arr[2] = arr[1];
			arr[1] = arr[0];
			arr[0] = val;
		}
		else if (val > arr[1])
		{
			arr[2] = arr[1];
			arr[1] = val;
		}
		else if (val > arr[2])
		{
			arr[2] = val;
		}
	}

	size_t part2(const std::vector<uint32_t>& elves)
	{
		std::array<uint32_t, 3> maxElves{};

		for (auto& elf : elves) {
			insertOrdered(maxElves, elf);
		}

		return maxElves[0] + maxElves[1] + maxElves[2];
	}
}

AOC_DAY(1)(const std::string& input)
{
	std::vector<uint32_t> elves;

	uint32_t currentElf = 0;
	uint32_t snack = 0;
	size_t i = 0;
	size_t l = input.length();

	while (i < l)
	{
		if (input[i] == '\n')
		{
			if (snack > 0)
			{
				currentElf += snack;
				snack = 0;
			}
			else
			{
				elves.emplace_back(currentElf);
				currentElf = 0;
			}
		}
		else
		{
			snack = (snack * 10) + (input[i] - '0');
		}

		i++;
	}

	if (currentElf > 0)
	{
		elves.emplace_back(currentElf + snack);
	}

	return {
		part1(elves),
		part2(elves)
	};
}