#include "aoc.h"
#include "helpers.h"

#include <set>
#include <vector>

namespace
{
	using Coord = std::pair<int, int>;
}

AOC_DAY(12)(const std::string& input)
{
	int width = input.find('\n');
	int height = (input.length() + 1) / (width + 1);

	auto heightAt = [&](const Coord& c) {
		auto h = input[c.first + (width + 1) * c.second];
		if (h == 'S')
			return 0;
		else if (h == 'E')
			return 'z' - 'a';
		else
			return h - 'a';
	};

	auto canClimb = [&](const Coord& to, int currentHeight) {
		auto diff = currentHeight - heightAt(to);
		return diff <= 1;
	};

	int start = input.find('S');
	int startX = start % (width + 1);
	int startY = start / (width + 1);

	int goal = input.find('E');
	int goalX = goal % (width + 1);
	int goalY = goal / (width + 1);

	std::vector<Coord> current;
	std::vector<Coord> next{ Coord{ goalX, goalY} };

	std::set<Coord> seen;

	auto pathLength = 0;

	auto p1 = 0;
	auto p2 = 0;

	while (!next.empty())
	{
		current = next;
		next.clear();
		++pathLength;

		for (auto& currentPos : current)
		{
			if (p2 == 0 && heightAt(currentPos) == 0)
			{
				p2 = pathLength - 1;
			}

			if (currentPos == Coord{ startX, startY})
			{
				p1 = pathLength - 1;
				next.clear();
				break;
			}

			if (seen.contains(currentPos))
			{
				continue;
			}

			seen.insert(currentPos);
			auto currentHeight = heightAt(currentPos);

			auto right = Coord{ currentPos.first + 1, currentPos.second };
			if (currentPos.first < (width - 1) && canClimb(right, currentHeight) && !seen.contains(right))
			{
				next.emplace_back(right);
			}

			auto left = Coord{ currentPos.first - 1, currentPos.second };
			if (currentPos.first > 0 && canClimb(left, currentHeight) && !seen.contains(left))
			{
				next.emplace_back(left);
			}

			auto down = Coord{ currentPos.first, currentPos.second + 1 };
			if (currentPos.second < (height - 1) && canClimb(down, currentHeight) && !seen.contains(down))
			{
				next.emplace_back(down);
			}

			auto up = Coord{ currentPos.first, currentPos.second - 1 };
			if (currentPos.second > 0 && canClimb(up, currentHeight) && !seen.contains(up))
			{
				next.emplace_back(up);
			}
		}
	}

	return { p1, p2 };
}