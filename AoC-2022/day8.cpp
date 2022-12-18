#include "aoc.h"
#include "helpers.h"

#include <algorithm>

namespace
{
#define coordIndex(x, y) y*(width + 1) + x
#define treeAt(x, y) input[coordIndex(x, y)] - '0'

	auto part1(const std::string& input, int width, int height)
	{
		auto visible = std::vector<bool>(height * (width + 1), false);

		for (auto y = 0; y < height; ++y)
		{
			auto min = -1;
			for (auto x = 0; x < width; ++x)
			{
				if (treeAt(x, y) > min)
				{
					visible[coordIndex(x, y)] = true;
					min = treeAt(x, y);
				}
			}

			min = -1;
			for (auto x = width - 1; x >= 0; --x)
			{
				if (treeAt(x, y) > min)
				{
					visible[coordIndex(x, y)] = true;
					min = treeAt(x, y);
				}
			}
		}

		for (auto x = 0; x < width; ++x)
		{
			auto min = -1;
			for (auto y = 0; y < height; ++y)
			{
				if (treeAt(x, y) > min)
				{
					visible[coordIndex(x, y)] = true;
					min = treeAt(x, y);
				}
			}

			min = -1;
			for (auto y = height - 1; y >= 0; --y)
			{
				if (treeAt(x, y) > min)
				{
					visible[coordIndex(x, y)] = true;
					min = treeAt(x, y);
				}
			}
		}

		return static_cast<int>(std::count(visible.begin(), visible.end(), true));
	}

	int scenicScore(int xStart, int yStart, const std::string& input, int width, int height)
	{
		auto scoreUp = 0;
		for (auto y = yStart - 1; y >= 0; --y)
		{
			++scoreUp;
			if (treeAt(xStart, y) >= treeAt(xStart, yStart))
			{
				break;
			}
		}

		auto scoreDown = 0;
		for (auto y = yStart + 1; y < height; ++y)
		{
			++scoreDown;
			if (treeAt(xStart, y) >= treeAt(xStart, yStart))
			{
				break;
			}
		}

		auto scoreLeft = 0;
		for (auto x = xStart - 1; x >= 0; --x)
		{
			++scoreLeft;
			if (treeAt(x, yStart) >= treeAt(xStart, yStart))
			{
				break;
			}
		}

		auto scoreRight = 0;
		for (auto x = xStart + 1; x < width; ++x)
		{
			++scoreRight;
			if (treeAt(x, yStart) >= treeAt(xStart, yStart))
			{
				break;
			}
		}

		return scoreUp * scoreDown * scoreLeft * scoreRight;
	}

	auto part2(const std::string& input, int width, int height)
	{
		auto max = 0;
		for (auto x = 0; x < width; ++x)
		{
			for (auto y = 0; y < height; ++y)
			{
				auto score = scenicScore(x, y, input, width, height);
				if (score > max)
				{
					max = score;
				}
			}
		}

		return max;
	}
}

AOC_DAY(8)(const std::string& input)
{
	auto width = static_cast<int>(input.find('\n'));
	auto height = static_cast<int>((input.length() + 1) / (width + 1));

	return { part1(input, width, height), part2(input, width, height) };
}