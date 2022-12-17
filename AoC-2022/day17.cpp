#include "aoc.h"
#include "helpers.h"

#include <cstdlib>
#include <sstream>
#include <unordered_map>

namespace
{
	constexpr auto ROOM_WIDTH = 7;
	constexpr auto P1_NUM_ROCKS = 2022;
	constexpr auto P2_NUM_ROCKS = 1000000000000;

	constexpr auto HASH_SIZE = 16;

	void printState(const std::vector<std::string>& rock, int x, int y, const std::vector<std::string>& cave)
	{
		auto rockWidth = rock.at(0).size();
		auto rockHeight = rock.size();
		auto visHeight = cave.size() + 7;
		for (int cy = visHeight - 1; cy >= 0; --cy)
		{
			if (y <= cy && cy < y + rockHeight)
			{
				for (auto cx = 0; cx < ROOM_WIDTH; ++cx)
				{
					if (cx < x || cx >= x + rockWidth)
					{
						std::cout << ".";
					}
					else
					{
						std::cout << rock.at(rockHeight - 1 - (cy - y)).at(cx - x);
					}
				}
				std::cout << std::endl;
			}
			else if (cy < cave.size())
			{
				std::cout << cave.at(cy) << std::endl;
			}
			else
			{
				std::cout << "......." << std::endl;
			}
		}
		std::cout << std::endl;
	}
}

AOC_DAY_REPS(17, 50)(const std::string& input)
{
	const auto rocks = std::vector{
		std::vector<std::string>{ "####" },
		std::vector<std::string>{
			".#.",
			"###",
			".#.",
		},
		std::vector<std::string>{
			"..#",
			"..#",
			"###",
		},
		std::vector<std::string>{
			"#",
			"#",
			"#",
			"#",
		},
		std::vector<std::string>{
			"##",
			"##",
		},
	};

	uint64_t rock = 0;
	auto jet = 0;

	auto detectCollision = [&](const std::vector<std::string>& rock, int x, int y, const std::vector<std::string>& cave) {
		if (x < 0)
			return true;

		if (y < 0)
			return true;

		if (x + rock[0].size() > ROOM_WIDTH)
			return true;

		if (y >= cave.size())
			return false;

		for (auto cy = y; cy < cave.size(); ++cy)
		{
			for (auto cx = x; cx < x + rock.at(0).size(); ++cx)
			{
				auto rocky = static_cast<int>(rock.size()) - 1 - (cy - y);
				if (rocky >= 0 && rocky < rock.size())
				{
					if (rock[rocky][cx - x] == '#' && cave[cy][cx] == '#')
					{
						return true;
					}
				}
			}
		}

		return false;
	};

	std::vector<std::string> cave;

	// spawn rock
	auto* rockType = &rocks.at(rock % rocks.size());
	auto rockWidth = rockType->at(0).size();
	auto rockHeight = rockType->size();
	auto x = 2;
	auto y = cave.size() + 3;

	uint64_t p1 = 0;
	uint64_t p2 = 0;

	std::unordered_map<std::string, uint64_t> seen;
	std::unordered_map<uint64_t, size_t> sizeAt;

	while (p1 == 0 || p2 == 0)
	{
		// printState(*rockType, x, y, cave);

		// jet push
		auto pushLeft = input[jet] == '<';
		jet = (jet + 1) % input.size();
		auto pushRight = !pushLeft;
		if (pushLeft && !detectCollision(*rockType, x - 1, y, cave))
		{
			x--;
		}
		else if (pushRight && !detectCollision(*rockType, x + 1, y, cave))
		{
			x++;
		}

		// printState(*rockType, x, y, cave);

		// fall down
		if (!detectCollision(*rockType, x, y - 1, cave))
		{
			y--;
		}
		else
		{
			for (auto ry = 0; ry < rockHeight; ++ry)
			{
				if (y + ry == cave.size())
				{
					std::stringstream ss{};
					for (auto cx = 0; cx < ROOM_WIDTH; ++cx)
					{
						if (cx < x || cx >= x + rockWidth)
						{
							ss << ".";
						}
						else
						{
							ss << rockType->at(rockHeight - 1 - ry).at(cx - x);
						}
					}
					cave.emplace_back(ss.str());
				}
				else if (y + ry < cave.size())
				{
					for (auto cx = x; cx < x + rockWidth; ++cx)
					{
						if (rockType->at(rockHeight - 1 - ry)[cx - x] == '#')
						{
							cave[y + ry][cx] = '#';
						}
					}
				}
			}

			// next rock
			rockType = &rocks.at(++rock % rocks.size());
			rockWidth = rockType->at(0).size();
			rockHeight = rockType->size();
			x = 2;
			y = cave.size() + 3;

			if (cave.size() > HASH_SIZE)
			{
				std::stringstream cavehash;

				for (auto h = cave.size() - 1 - HASH_SIZE; h < cave.size(); ++h)
				{
					cavehash << cave.at(h);
				}
				cavehash << (rock % rocks.size()) << jet;

				auto hash = cavehash.str();
				if (seen.contains(hash))
				{
					auto cycleLength = rock - seen.at(hash);
					auto dSize = cave.size() - sizeAt.at(seen.at(hash));

					// p1
					auto p1ops = std::div(static_cast<long long>(P1_NUM_ROCKS - seen.at(hash)), cycleLength);
					p1 = sizeAt.at(seen.at(hash) + p1ops.rem) + p1ops.quot * dSize;

					// p2
					auto p2ops = std::div(static_cast<long long>(P2_NUM_ROCKS - seen.at(hash)), cycleLength);
					p2 = sizeAt.at(seen.at(hash) + p2ops.rem) + p2ops.quot * dSize;
				}
				else
				{
					seen.emplace(std::move(hash), rock);
				}
			}

			sizeAt.emplace(rock, cave.size());
			continue;
		}
	}

	return { p1, p2 };
}