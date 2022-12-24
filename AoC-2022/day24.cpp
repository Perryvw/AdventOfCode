#include "aoc.h"
#include "helpers.h"

#include <unordered_set>

namespace
{
	struct Blizzard {
		int startX;
		int startY;
		char direction;
	};

	std::unordered_set<Point> blizzardsAtTime(int t, const std::vector<Blizzard>& blizzards, int width, int height)
	{
		std::unordered_set<Point> result;

		for (auto& blizzard : blizzards)
		{
			if (blizzard.direction == '>')
			{
				auto currentX = ((blizzard.startX - 1 + t) % (width - 2)) + 1;
				result.insert({ currentX, blizzard.startY });
			}
			else if (blizzard.direction == '<')
			{
				auto currentX = posmod(blizzard.startX - 1 - t, width - 2) + 1;
				result.insert({ currentX, blizzard.startY });
			}
			else if (blizzard.direction == 'v')
			{
				auto currentY = ((blizzard.startY - 1 + t) % (height - 2)) + 1;
				result.insert({ blizzard.startX, currentY });
			}
			else if (blizzard.direction == '^')
			{
				auto currentY = posmod(blizzard.startY - 1 - t, height - 2) + 1;
				result.insert({ blizzard.startX, currentY });
			}
		}

		return result;
	}

	int timeToTravel(int startTime, Point from, Point to, const std::vector<Blizzard>& blizzards, int width, int height)
	{
		auto t = startTime;
		std::unordered_set<Point> current{ from };
		std::unordered_set<Point> next{};

		while (t < 5000)
		{
			auto nextBlizzards = blizzardsAtTime(t + 1, blizzards, width, height);

			for (auto& p : current)
			{
				if (p.x == to.x && p.y == to.y)
				{
					return t - startTime;
				}

				if (!nextBlizzards.contains({ p.x, p.y }))
				{
					next.insert({ p.x, p.y });
				}

				if (p.x > 1 && p.y > 0 && p.y < height - 1 && !nextBlizzards.contains({ p.x - 1, p.y }))
				{
					next.insert({ p.x - 1, p.y });
				}
				if (p.x < width - 2 && p.y > 0 && p.y < height - 1 && !nextBlizzards.contains({ p.x + 1, p.y }))
				{
					next.insert({ p.x + 1, p.y });
				}
				if ((p.y > 1 || p.x == to.x) && !nextBlizzards.contains({ p.x, p.y - 1 }))
				{
					next.insert({ p.x, p.y - 1 });
				}
				if ((p.y < height - 2 || p.x == to.x) && !nextBlizzards.contains({ p.x, p.y + 1 }))
				{
					next.insert({ p.x, p.y + 1 });
				}
			}

			t++;
			current = std::move(next);
			next = {};
		}

		throw "nothing found";
	}
}

AOC_DAY_REPS(24, 5)(const std::string& input)
{
	std::vector<Blizzard> blizzards;

	auto height = 0;
	auto width = 0;
	ForEachLine(input, [&](std::string_view line) {
		width = line.size();
		for (auto x = 0; x < width; x++)
		{
			if (line[x] != '#' && line[x] != '.')
			{
				blizzards.emplace_back(x, height, line[x]);
			}
		}
		height++;
	});

	Point start{ 1, 0 };
	Point end{ width - 2, height - 1 };

	auto p1 = timeToTravel(0, start, end, blizzards, width, height);
	auto back = timeToTravel(p1, end, start, blizzards, width, height);
	auto backAgain = timeToTravel(p1 + back, start, end, blizzards, width, height);

	return { p1, p1 + back + backAgain };
}