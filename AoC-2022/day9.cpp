#include "aoc.h"
#include "helpers.h"

#include <unordered_set>

namespace
{
	long hash(int x, int y) { return x * 100000 + y; }
}

AOC_DAY(9)(const std::string& input)
{
	int head_x = 0;
	int head_y = 0;
	int tail_x = 0;
	int tail_y = 0;

	std::unordered_set<long> seen{};

	ForEachLine(input, [&](const std::string_view& line) {
		auto num = std::stoi(line.data() + 2);

		for (auto i = 0; i < num; i++)
		{
			if (line[0] == 'U')
				++head_y;
			else if (line[0] == 'D')
				--head_y;
			else if (line[0] == 'L')
				--head_x;
			else if (line[0] == 'R')
				++head_x;

			if (head_x != tail_x && head_y != tail_y)
			{
				// diagonal move
				if (head_x - tail_x > 1)
				{
					tail_x = head_x - 1;
					tail_y = head_y;
				}
				else if (tail_x - head_x > 1)
				{
					tail_x = head_x + 1;
					tail_y = head_y;
				}
				else if (head_y - tail_y > 1)
				{
					tail_y = head_y - 1;
					tail_x = head_x;
				}
				else if (tail_x - head_x > 1)
				{
					tail_y = head_y + 1;
					tail_x = head_x;
				}
			}
			else if (head_x != tail_x)
			{
				if (head_x > tail_x)
				{
					tail_x = head_x - 1;
				}
				else
				{
					tail_x = head_x + 1;
				}
			}
			else if (head_y != tail_y)
			{
				if (head_y > tail_y)
				{
					tail_y = head_y - 1;
				}
				else
				{
					tail_y = head_y + 1;
				}
			}

			seen.insert(hash(tail_x, tail_y));
		}
		std::cout << tail_x << "," << tail_y << " - " << seen.size() << " (" << line << ")" << std::endl;
	});

	for (auto y = 0; y < 12; y++)
	{
		for (auto x = 0; x < 12; x++)
		{
			std::cout << (seen.contains(hash(x-6, y-6)) ? "#" : ".");
		}
		std::cout << std::endl;
	}

	return { seen.size(), 0 };
}