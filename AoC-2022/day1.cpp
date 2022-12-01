#include "aoc.h"

#include <array>
#include <sstream>

size_t part1(const std::string& input)
{
	std::stringstream ss{ input };
	std::string line;

	uint32_t currentElf = 0;
	uint32_t maxElf = 0;

	while (std::getline(ss, line))
	{
		if (line.size() > 0)
		{
			currentElf += stoi(line);
		}
		else
		{
			if (currentElf > maxElf)
			{
				maxElf = currentElf;
			}
			currentElf = 0;
		}
	}

	if (currentElf > maxElf)
	{
		maxElf = currentElf;
	}

	return maxElf;
}

size_t part2(const std::string& input)
{
	std::stringstream ss{ input };
	std::string line;

	uint32_t currentElf = 0;
	std::array<uint32_t, 3> maxElves{};

	while (std::getline(ss, line))
	{
		if (line.size() > 0)
		{
			currentElf += stoi(line);
		}
		else
		{
			if (currentElf > maxElves[0])
			{
				maxElves[2] = maxElves[1];
				maxElves[1] = maxElves[0];
				maxElves[0] = currentElf;
			}
			else if (currentElf > maxElves[1])
			{
				maxElves[2] = maxElves[1];
				maxElves[1] = currentElf;
			}
			else if (currentElf > maxElves[2])
			{
				maxElves[2] = currentElf;
			}

			currentElf = 0;
		}
	}

	if (currentElf > maxElves[0])
	{
		maxElves[2] = maxElves[1];
		maxElves[1] = maxElves[0];
		maxElves[0] = currentElf;
	}
	else if (currentElf > maxElves[1])
	{
		maxElves[2] = maxElves[1];
		maxElves[1] = currentElf;
	}
	else if (currentElf > maxElves[2])
	{
		maxElves[2] = currentElf;
	}

	return maxElves[0] + maxElves[1] + maxElves[2];
}

AOC_DAY(1)(const std::string& input)
{
	return { 
		part1(input),
		part2(input)
	};
}