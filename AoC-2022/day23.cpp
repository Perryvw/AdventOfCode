#include "aoc.h"
#include "helpers.h"

#include <unordered_set>
#include <vector>

namespace
{
	constexpr auto NUM_ROUNDS_P1 = 10;

	using ElfSet = std::unordered_set<Point>;
	using MultiElfMap = std::unordered_map<Point, std::vector<Point>>;

	bool isElfInPosition(int x, int y, const ElfSet& elves) { return elves.contains(Point{ x, y }); }
	bool isElfNorthOf(int x, int y, const ElfSet& elves)
	{
		return isElfInPosition(x - 1, y - 1, elves) || isElfInPosition(x, y - 1, elves) || isElfInPosition(x + 1, y - 1, elves);
	}
	bool isElfSouthOf(int x, int y, const ElfSet& elves)
	{
		return isElfInPosition(x - 1, y + 1, elves) || isElfInPosition(x, y + 1, elves) || isElfInPosition(x + 1, y + 1, elves);
	}
	bool isElfWestOf(int x, int y, const ElfSet& elves)
	{
		return isElfInPosition(x - 1, y - 1, elves) || isElfInPosition(x - 1, y, elves) || isElfInPosition(x - 1, y + 1, elves);
	}
	bool isElfEastOf(int x, int y, const ElfSet& elves)
	{
		return isElfInPosition(x + 1, y - 1, elves) || isElfInPosition(x + 1, y, elves) || isElfInPosition(x + 1, y + 1, elves);
	}
	bool isElfAround(const Point& p, const ElfSet& elves)
	{
		return isElfNorthOf(p.x, p.y, elves) || isElfSouthOf(p.x, p.y, elves) || isElfInPosition(p.x - 1, p.y, elves)
			   || isElfInPosition(p.x + 1, p.y, elves);
	}
}

AOC_DAY_REPS(23, 2)(const std::string& input)
{
	ElfSet points;
	auto y = 0;
	ForEachLine(input, [&](std::string_view line) {
		for (auto x = 0; x < line.length(); x++)
		{
			if (line[x] == '#')
			{
				points.emplace(x, y);
			}
		}
		++y;
	});

	auto p1 = 0;
	auto p2 = 0;

	for (auto round = 0;; ++round)
	{
		MultiElfMap considered;
		considered.reserve(points.size());

		auto emplaceOrAdd = [&](const Point& p, Point elf) {
			if (considered.contains(p))
			{
				considered.at(p).emplace_back(elf);
			}
			else
			{
				considered.emplace(p, std::vector<Point>{ elf });
			}
		};

		for (auto& point : points)
		{
			if (!isElfAround(point, points))
			{
				continue;
			}
			else
			{
				for (int i = 0; i < 4; ++i)
				{
					auto check = (round + i) % 4;
					if (check == 0 && !isElfNorthOf(point.x, point.y, points))
					{
						emplaceOrAdd(Point{ point.x, point.y - 1 }, point);
						break;
					}
					if (check == 1 && !isElfSouthOf(point.x, point.y, points))
					{
						emplaceOrAdd(Point{ point.x, point.y + 1 }, point);
						break;
					}
					if (check == 2 && !isElfWestOf(point.x, point.y, points))
					{
						emplaceOrAdd(Point{ point.x - 1, point.y }, point);
						break;
					}
					if (check == 3 && !isElfEastOf(point.x, point.y, points))
					{
						emplaceOrAdd(Point{ point.x + 1, point.y }, point);
						break;
					}
				}
			}
		}

		if (considered.empty())
		{
			p2 = round + 1;
			break;
		}

		for (auto& [destination, froms] : considered)
		{
			if (froms.size() == 1)
			{
				points.erase(froms[0]);
				points.emplace(destination);
			}
		}

		if (round == NUM_ROUNDS_P1 - 1)
		{
			Point mins{};
			Point maxs{};

			for (auto& p : points)
			{
				if (p.x < mins.x)
					mins.x = p.x;
				if (p.x > maxs.x)
					maxs.x = p.x;
				if (p.y < mins.y)
					mins.y = p.y;
				if (p.y > maxs.y)
					maxs.y = p.y;
			}
			p1 = (maxs.x - mins.x + 1) * (maxs.y - mins.y + 1) - points.size();
		}
	}

	return { p1, p2 };
}