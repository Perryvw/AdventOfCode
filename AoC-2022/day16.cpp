#include "aoc.h"
#include "helpers.h"

#include <queue>
#include <unordered_map>
#include <unordered_set>

namespace
{
	using ValveStates = uint64_t;

	struct State {
		int t;
		int pos;
		ValveStates valves;
		int p;

		friend bool operator<(const State& lhs, const State& rhs) { return lhs.p < rhs.p; }
	};

	std::vector<std::pair<int, int>> findEdges(const std::string& valve,
		const std::unordered_map<std::string, std::vector<std::string>>& tunnels, const std::unordered_map<int, long>& flowValues,
		const std::unordered_map<std::string, int>& names, const std::unordered_set<std::string>& seen)
	{
		if (seen.contains(valve))
		{
			return {};
		}
		std::unordered_set<std::string> seen2{ seen };
		seen2.insert(valve);

		std::vector<std::pair<int, int>> result;

		for (auto& tunnel : tunnels.at(valve))
		{
			if (flowValues.at(names.at(tunnel)) > 0 && !seen.contains(tunnel))
			{
				result.emplace_back(names.at(tunnel), 1);
			}
			else
			{
				for (auto& [connectedValve, cost] : findEdges(tunnel, tunnels, flowValues, names, seen2))
				{
					result.emplace_back(connectedValve, cost + 1);
				}
			}
		}

		return result;
	}
}

FOCUS_AOC_DAY(16)(const std::string& input)
{
	std::unordered_map<int, long> flowValues;
	std::unordered_map<std::string, std::vector<std::string>> tunnels;

	std::unordered_map<std::string, int> names;

	ForEachLine(input, [&](std::string_view line) {
		auto name = std::string{ line.substr(6, 2) };
		int nameId = names.size();

		if (names.contains(name))
		{
			nameId = names.at(name);
		}
		else
		{
			names.emplace(name, nameId);
		}

		char* stringPtr;
		auto flowRate = strtol(line.data() + 23, &stringPtr, 10);
		if (*(stringPtr + 8) == 's')
		{
			stringPtr += 25;
		}
		else
		{
			stringPtr += 24;
		}

		auto lineEnd = line.data() + line.size();

		std::vector<std::string> connectedTunnels;

		while (stringPtr < lineEnd)
		{
			connectedTunnels.emplace_back(std::string_view{ stringPtr, 2 });
			stringPtr += 4;
		}

		flowValues.emplace(nameId, flowRate);
		tunnels.emplace(name, std::move(connectedTunnels));
	});

	std::unordered_map<int, std::vector<std::pair<int, int>>> edges;

	for (auto& [valve, _] : tunnels)
	{
		std::unordered_set<std::string> seen{};
		edges.emplace(names.at(valve), findEdges(valve, tunnels, flowValues, names, seen));
	}

	auto maxFlow = 0;
	for (auto& [_, flow] : flowValues)
	{
		maxFlow += flow;
	}

	State state{};
	state.t = 1;
	state.pos = names.at("AA");

	std::priority_queue<State> queue{};
	queue.push(state);

	uint64_t maxp = 0;

	std::unordered_map<uint64_t, int> cache;

	//std::vector<int> choices{
	//	-1,
	//	names.at("DD"),
	//	-1,
	//	names.at("BB"),
	//	names.at("BB"),
	//	-1,
	//	names.at("JJ"),
	//	names.at("II"),
	//	names.at("JJ"),
	//	-1,
	//	names.at("DD"),
	//	-1, // names.at("AA"),
	//	-1, // names.at("DD"),
	//	names.at("EE"),
	//	names.at("HH"), // names.at("FF"),
	//	-1,				// names.at("GG"),
	//	-1,// names.at("HH"),
	//	-1,
	//	names.at("EE"), // GG
	//	names.at("FF"),
	//	names.at("EE"),
	//	-1,
	//	names.at("DD"),
	//	names.at("CC"),
	//	-1,
	//};

	while (!queue.empty())
	{
		auto state = std::move(queue.top());
		queue.pop();

		uint64_t hash = state.pos * 100000 + state.t * 3000 + state.p;
		//uint64_t hash = (state.valves << 20) + (state.pos << 7) + state.t;
		if (cache.find(hash) != cache.end() && cache.at(hash) >= state.p)
		{
			continue;
		}
		cache.emplace(hash, state.p);

		if (state.p > maxp)
		{
			maxp = state.p;
		}

		if (state.t == 30)
		{
			continue;
		}

		if (state.p + maxFlow * (30 - state.t) < maxp)
		{
			continue;
		}

		// Do nothing until end
		{
			State newState{ state };
			newState.t = 30;

			for (auto v = 0; v < flowValues.size(); ++v)
			{
				if (newState.valves & (1ll << v))
				{
					newState.p += (30 - state.t) * flowValues.at(v);
				}
			}
			queue.push(newState);
		}


		if ((state.valves & 1ll << state.pos) == 0 && flowValues.at(state.pos) > 0)
		{
			State newState{ state };
			++newState.t;

			newState.valves |= 1ll << state.pos;
			for (auto v = 0; v < flowValues.size(); ++v)
			{
				if (newState.valves & (1ll << v))
				{
					newState.p += flowValues.at(v);
				}
			}

			queue.push(newState);
		}

		for (auto& [otherValve, cost] : edges.at(state.pos))
		{
			//if (state.t < choices.size() && otherValve == choices.at(state.t))
			if (state.t + cost <= 30)
			{
				State newState{ state };
				newState.t += cost;
				newState.pos = otherValve;

				for (auto v = 0; v < flowValues.size(); ++v)
				{
					if (state.valves & (1ll << v))
					{
						newState.p += cost * flowValues.at(v);
					}
				}

				queue.push(newState);
			}
		}
	}

	return { maxp, 0 };
}