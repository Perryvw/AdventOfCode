#include "aoc.h"

#include <unordered_set>

int hash(int x, int y)
{
	return x * 10000 + y;
}

int moveAndDeliver(int& x, int& y, char c, std::unordered_set<int>& seen)
{
	int delivered = 0;

	switch (c) {
	case '>': x++; break;
	case '<': x--; break;
	case '^': y++; break;
	case 'v': y--; break;
	}
	if (!seen.contains(hash(x, y)))
		delivered = 1;
	seen.insert(hash(x, y));

	return delivered;
}

size_t part1(const std::string& input)
{
	auto x = 0;
	auto y = 0;

	std::unordered_set<int> seen;
	auto delivered = 1;
	seen.insert(hash(x, y));

	for (auto& c : input)
	{
		delivered += moveAndDeliver(x, y, c, seen);
	}

	return delivered;
}

size_t part2(const std::string& input)
{
	auto x = 0;
	auto y = 0;
	auto rx = 0;
	auto ry = 0;

	std::unordered_set<int> seen;
	auto delivered = 1;
	seen.insert(hash(x, y));

	for (auto i = 0; i < input.size(); i++)
	{
		if (i % 2 == 0)
		{
			delivered += moveAndDeliver(x, y, input[i], seen);
		}
		else
		{
			delivered += moveAndDeliver(rx, ry, input[i], seen);
		}
	}

	return delivered;
}

AOC_DAY(1)(const std::string& input)
{
	return { 
		std::to_string(part1(input)),
		std::to_string(part2(input))
	};
}