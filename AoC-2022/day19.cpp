#include "aoc.h"
#include "helpers.h"

#include <queue>
#include <unordered_set>

namespace {
	constexpr auto TOTAL_MINUTES = 24;

	struct Blueprint
	{
		int OreRobotOreCost;
		int ClayRobotOreCost;
		int ObsidianRobotOreCost;
		int ObsidianRobotClayCost;
		int GeodeRobotOreCost;
		int GeodeRobotObsidianCost;
	};

	struct Resources
	{
		int t;
		int OreRobots;
		int ClayRobots;
		int ObsidianRobots;
		int GeodeRobots;

		int Ore;
		int Clay;
		int Obsidian;
		int Geodes;
	};

	uint64_t hash(const Resources& r)
	{
		return static_cast<uint64_t>(r.t) << 32 + r.OreRobots << 24 + r.ClayRobots << 16 + r.ObsidianRobots << 8 + r.GeodeRobots;
	}

	int hashRobots(const Resources& r)
	{
		return r.OreRobots << 24 + r.ClayRobots << 16 + r.ObsidianRobots << 8 + r.GeodeRobots;
	}

	std::vector<Resources> spendingCombinations(const Resources& r, const Blueprint& bp)
	{
		std::vector<Resources> result;
		result.emplace_back(r);
		std::unordered_set<int> seen;

		if (r.Ore >= bp.OreRobotOreCost)
		{
			Resources newState{r};
			newState.Ore -= bp.OreRobotOreCost;
			newState.OreRobots++;
			for (auto& s : spendingCombinations(newState, bp))
			{
				auto hash = hashRobots(s);
				if (!seen.contains(hash))
				{
					seen.emplace(hash);
					result.emplace_back(s);
				}
			}
		}

		if (r.Ore >= bp.ClayRobotOreCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.ClayRobotOreCost;
			newState.ClayRobots++;
			for (auto& s : spendingCombinations(newState, bp))
			{
				auto hash = hashRobots(s);
				if (!seen.contains(hash))
				{
					seen.emplace(hash);
					result.emplace_back(s);
				}
			}
		}

		if (r.Ore >= bp.ObsidianRobotOreCost && r.Clay >= bp.ObsidianRobotClayCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.ObsidianRobotOreCost;
			newState.Clay -= bp.ObsidianRobotClayCost;
			newState.ObsidianRobots++;
			for (auto& s : spendingCombinations(newState, bp))
			{
				auto hash = hashRobots(s);
				if (!seen.contains(hash))
				{
					seen.emplace(hash);
					result.emplace_back(s);
				}
			}
		}

		if (r.Ore >= bp.GeodeRobotOreCost && r.Obsidian >= bp.GeodeRobotObsidianCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.GeodeRobotOreCost;
			newState.Obsidian -= bp.GeodeRobotObsidianCost;
			newState.GeodeRobots++;
			for (auto& s : spendingCombinations(newState, bp))
			{
				auto hash = hashRobots(s);
				if (!seen.contains(hash))
				{
					seen.emplace(hash);
					result.emplace_back(s);
				}
			}
		}

		return result;
	}

	auto divRoundUp(int a, int b)
	{
		return (a + b - 1) / b;
	}

	auto timeLeft(const Resources& r)
	{
		return TOTAL_MINUTES - r.t;
	}

	auto heuristic_firstClayRobotProducedAt(const Resources& r, const Blueprint& bp)
	{
		if (r.ClayRobots > 0) return 0;
		if (r.Ore > bp.ClayRobotOreCost) return r.t + 1;

		return r.t + 1 + divRoundUp(bp.ClayRobotOreCost - r.Ore, r.OreRobots);
	}

	auto heuristic_firstObsidianRobotProducedAt(const Resources& r, const Blueprint& bp)
	{
		if (r.ObsidianRobots > 0) return 0;
		if (r.Ore > bp.ObsidianRobotOreCost && r.Clay > bp.ObsidianRobotClayCost) return r.t + 1;

		auto oreTimeLeft = r.Ore < bp.ObsidianRobotOreCost ? divRoundUp(bp.ObsidianRobotOreCost - r.Ore, std::max(1, r.OreRobots)) : 0;
		auto clayTimeLeft = r.Clay < bp.ObsidianRobotClayCost ? divRoundUp(bp.ObsidianRobotClayCost - r.Clay, std::max(1, r.ClayRobots)) : 0;

		return heuristic_firstClayRobotProducedAt(r, bp) + std::max(oreTimeLeft, clayTimeLeft);
	}

	auto heuristic_firstGeodeProducedAt(const Resources& r, const Blueprint& bp)
	{
		if (r.GeodeRobots > 0) return 0;
		if (r.Ore > bp.GeodeRobotOreCost && r.Obsidian > bp.GeodeRobotObsidianCost) return r.t + 1;

		auto oreTimeLeft = r.Ore < bp.GeodeRobotOreCost ? divRoundUp(bp.GeodeRobotOreCost - r.Ore, std::max(1, r.OreRobots)) : 0;
		auto obsidianTimeLeft = r.Obsidian < bp.GeodeRobotObsidianCost ? divRoundUp(bp.GeodeRobotObsidianCost - r.Obsidian, std::max(1, r.ObsidianRobots)) : 0;

		return heuristic_firstObsidianRobotProducedAt(r, bp) + std::max(oreTimeLeft, obsidianTimeLeft);
	}

	int maxGeodes(const Blueprint& blueprint)
	{
		Resources initialState{};
		initialState.t = 0;
		initialState.OreRobots = 1;

		int maxGeodes = 3;

		std::unordered_map<uint64_t, int> seen;

		std::queue<Resources> q;
		q.emplace(initialState);

		while (!q.empty())
		{
			auto state = std::move(q.front());
			q.pop();

			state.t++;

			state.Ore += state.OreRobots;
			state.Clay += state.ClayRobots;
			state.Obsidian += state.ObsidianRobots;
			state.Geodes += state.GeodeRobots;

			if (state.Geodes > maxGeodes)
			{
				maxGeodes = state.Geodes;
				std::cout << maxGeodes << std::endl;
			}

			if (state.t == TOTAL_MINUTES)
			{
				continue;
			}

			if (heuristic_firstGeodeProducedAt(state, blueprint) > TOTAL_MINUTES)
			{
				continue; // prune not enough time left to exceed max
			}

			auto h = hash(state);
			if (seen.contains(h))
			{
				if (seen.at(h) > state.Geodes)
				{
					continue;
				}
				else
				{
					seen.at(h) = state.Geodes;
				}
			}
			else
			{
				seen.emplace(h, state.Geodes);
			}

			for (auto& ns : spendingCombinations(state, blueprint))
			{
				q.emplace(ns);
			}
		}

		return maxGeodes;
	}
}

FOCUS_AOC_DAY(19)(const std::string& input)
{
	std::vector<Blueprint> blueprints;

	ForEachLine(input, [&](std::string_view line) {
		Blueprint blueprint{};
		char* linePtr;
		auto blueprintNr = strtol(line.data() + 10, &linePtr, 10);

		blueprint.OreRobotOreCost = strtol(linePtr + 23, &linePtr, 10);

		blueprint.ClayRobotOreCost = strtol(linePtr + 28, &linePtr, 10);

		blueprint.ObsidianRobotOreCost = strtol(linePtr + 32, &linePtr, 10);
		blueprint.ObsidianRobotClayCost = strtol(linePtr + 9, &linePtr, 10);

		blueprint.GeodeRobotOreCost = strtol(linePtr + 30, &linePtr, 10);
		blueprint.GeodeRobotObsidianCost = strtol(linePtr + 9, &linePtr, 10);

		blueprints.emplace_back(std::move(blueprint));
	});

	auto test = maxGeodes(blueprints[0]);

	return { 0, 0 };
}