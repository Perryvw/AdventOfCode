#include "aoc.h"
#include "helpers.h"

#include <queue>
#include <unordered_set>

namespace
{
	constexpr auto P1_MINUTES = 24;
	constexpr auto P2_MINUTES = 32;

	struct Blueprint {
		int OreRobotOreCost;
		int ClayRobotOreCost;
		int ObsidianRobotOreCost;
		int ObsidianRobotClayCost;
		int GeodeRobotOreCost;
		int GeodeRobotObsidianCost;
	};

	struct Maxes {
		int maxOreCost;
		int maxClayCost;
		int maxObsidianCost;
	};

	struct Resources {
		int t;
		int OreRobots;
		int ClayRobots;
		int ObsidianRobots;
		int GeodeRobots;

		int Ore;
		int Clay;
		int Obsidian;
		int Geodes;

		int priority() const
		{
			return GeodeRobots * 1000 + ObsidianRobots * 100 + ClayRobots * 10;
			/*auto rOreClay = 9.0f / 14.0f;
			auto rOreOb = 9.0f / 7.0f;
			auto rClayOb = 14.0f / 7.0f;

			auto actualOC = (OreRobots + 1) / static_cast<float>(ClayRobots + 1);
			auto actualOO = (OreRobots + 1) / static_cast<float>(ObsidianRobots + 1);
			auto actualCO = (ClayRobots + 1) / static_cast<float>(ObsidianRobots + 1);

			return 20 * GeodeRobots + 5*ObsidianRobots + 3*ClayRobots + OreRobots - std::abs(actualOC - rOreClay) - std::abs(actualOO -
			rOreOb) - std::abs(actualCO - rClayOb);*/
		}

		bool operator<(const Resources& rhs) const { return priority() < rhs.priority(); }
	};

	uint64_t hash(const Resources& r)
	{
		auto robotsHash = (r.OreRobots << 24) | (r.ClayRobots << 16) | (r.ObsidianRobots << 8) | r.GeodeRobots;
		auto resourceHash = (r.Ore << 24) | (r.Clay << 16) | (r.Obsidian << 8) | r.Geodes;
		return (static_cast<uint64_t>(robotsHash) << 32) | resourceHash;
	}

	int hashRobots(const Resources& r) { return (r.OreRobots << 24) | (r.ClayRobots << 16) | (r.ObsidianRobots << 8) | r.GeodeRobots; }

	std::vector<Resources> spendingCombinations(const Resources& r, const Blueprint& bp, const Maxes& maxes)
	{
		std::vector<Resources> result;
		result.emplace_back(r);

		if (r.Ore >= bp.OreRobotOreCost && r.OreRobots < maxes.maxOreCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.OreRobotOreCost;
			newState.OreRobots++;
			result.emplace_back(std::move(newState));
		}

		if (r.Ore >= bp.ClayRobotOreCost && r.ClayRobots < maxes.maxClayCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.ClayRobotOreCost;
			newState.ClayRobots++;
			result.emplace_back(std::move(newState));
		}

		if (r.Ore >= bp.ObsidianRobotOreCost && r.Clay >= bp.ObsidianRobotClayCost && r.ObsidianRobots < maxes.maxObsidianCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.ObsidianRobotOreCost;
			newState.Clay -= bp.ObsidianRobotClayCost;
			newState.ObsidianRobots++;
			result.emplace_back(std::move(newState));
		}

		if (r.Ore >= bp.GeodeRobotOreCost && r.Obsidian >= bp.GeodeRobotObsidianCost)
		{
			Resources newState{ r };
			newState.Ore -= bp.GeodeRobotOreCost;
			newState.Obsidian -= bp.GeodeRobotObsidianCost;
			newState.GeodeRobots++;
			result.emplace_back(std::move(newState));
		}

		return result;
	}

	int timeLeft(const Resources& r, unsigned totalTime) { return static_cast<int>(totalTime) - r.t; }

	int maxGeodes(const Blueprint& blueprint, unsigned time)
	{
		Resources initialState{};
		initialState.t = 0;
		initialState.OreRobots = 1;

		int maxGeodes = 0;
		Maxes maxes{
			std::max(blueprint.OreRobotOreCost,
				std::max(blueprint.ClayRobotOreCost, std::max(blueprint.ObsidianRobotOreCost, blueprint.GeodeRobotOreCost))),
			blueprint.ObsidianRobotClayCost,
			blueprint.GeodeRobotObsidianCost,
		};

		std::unordered_map<uint64_t, int> seen;

		std::queue<Resources> q;
		q.emplace(initialState);

		while (!q.empty())
		{
			auto state = std::move(q.front());
			q.pop();

			if (state.Geodes > maxGeodes)
			{
				maxGeodes = state.Geodes;
			}

			if (state.t == time)
			{
				continue;
			}

			state.Ore = std::min(state.Ore, maxes.maxOreCost * timeLeft(state, time));
			state.Clay = std::min(state.Clay, maxes.maxClayCost * timeLeft(state, time));
			state.Obsidian = std::min(state.Obsidian, maxes.maxObsidianCost * timeLeft(state, time));

			auto h = hash(state);
			if (seen.contains(h))
			{
				continue;
			}
			else
			{
				seen.emplace(h, state.Geodes);
			}

			for (auto& ns : spendingCombinations(state, blueprint, maxes))
			{
				ns.t++;

				ns.Ore += state.OreRobots;
				ns.Clay += state.ClayRobots;
				ns.Obsidian += state.ObsidianRobots;
				ns.Geodes += state.GeodeRobots;

				q.push(ns);
			}
		}

		return maxGeodes;
	}
}

AOC_DAY(19)(const std::string& input)
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

	/*auto p1 = 0;
	auto id = 1;
	for (auto& bp : blueprints)
	{
		auto m = maxGeodes(bp, P1_MINUTES);
		p1 += m * id++;
		std::cout << (id - 1) << "/" << blueprints.size() << std::endl;
	}

	auto p2 = 1;
	auto id1 = 1;
	for (auto& bp : blueprints)
	{
		p2 *= maxGeodes(bp, P2_MINUTES);
		std::cout << id1++ << "/" << blueprints.size() << std::endl;
		if (id1 == 4)
			break;
	}

	return { p1, p2 };*/

	return { "runtime too high", "runtime too high" };
}