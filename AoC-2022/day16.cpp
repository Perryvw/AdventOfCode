#include "aoc.h"
#include "helpers.h"

#include <array>
#include <queue>
#include <unordered_map>
#include <unordered_set>

namespace
{
	constexpr auto TIME_P1 = 30;
	constexpr auto TIME_P2 = 26;

	using ValveStates = uint64_t;
	using EdgeList = std::unordered_map<int, std::vector<std::pair<int, int>>>;
	using FlowValues = std::unordered_map<int, long>;

	struct State {
		int t;
		int pos;
		int rate;
		ValveStates valves;
		int p;
	};

	struct State2 : State {
		int posElephant;
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

	template <typename T> T openValve(const T& state, const FlowValues& flowValues, int pos)
	{
		T newState{ state };

		newState.valves |= 1ll << pos;
		newState.rate = 0;
		for (auto v = 0; v < flowValues.size(); ++v)
		{
			if (newState.valves & (1ll << v))
			{
				newState.rate += flowValues.at(v);
			}
		}
		newState.p += newState.rate;
		return newState;
	}

	int part1(const EdgeList& edges, const FlowValues& flowValues, int initialPos)
	{
		auto maxFlow = 0;
		for (auto& [_, flow] : flowValues)
		{
			maxFlow += flow;
		}

		State state{};
		state.t = 1;
		state.pos = initialPos;
		state.rate = 0;

		std::queue<State> queue{};
		queue.push(state);

		int maxp = 0;

		std::unordered_map<uint64_t, int> cache;

		while (!queue.empty())
		{
			auto state = std::move(queue.front());
			queue.pop();

			uint64_t hash = state.pos * 100000 + state.t * 3000 + state.p;
			if (cache.find(hash) != cache.end())
			{
				if (cache.at(hash) >= state.p)
				{
					continue;
				}
				else
				{
					cache[hash] = state.p;
				}
			}
			else
			{
				cache.emplace(hash, state.p);
			}

			if (state.p > maxp)
			{
				maxp = state.p;
			}

			if (state.t == TIME_P1)
			{
				continue;
			}

			if (state.p + maxFlow * (TIME_P1 - state.t) < maxp)
			{
				continue;
			}

			// Do nothing until end
			{
				State newState{ state };
				newState.t = TIME_P1;

				newState.p += (TIME_P1 - state.t) * newState.rate;

				queue.push(newState);
			}

			if ((state.valves & 1ll << state.pos) == 0 && flowValues.at(state.pos) > 0)
			{
				State newState = openValve(state, flowValues, state.pos);
				++newState.t;
				queue.push(newState);
			}

			for (auto& [otherValve, cost] : edges.at(state.pos))
			{
				if (state.t + cost <= TIME_P1)
				{
					State newState{ state };
					newState.t += cost;
					newState.pos = otherValve;

					newState.p += newState.rate * cost;

					queue.push(newState);
				}
			}
		}

		return maxp;
	}

	int part2(const EdgeList& edges, const FlowValues& flowValues, int initialPos)
	{
		auto maxFlow = 0;
		for (auto& [_, flow] : flowValues)
		{
			maxFlow += flow;
		}

		State2 state{};
		state.t = 1;
		state.pos = initialPos;
		state.posElephant = initialPos;
		state.rate = 0;

		std::queue<State2> queue{};
		queue.push(state);

		int maxp = 0;

		std::unordered_map<uint64_t, int> cache;

		while (!queue.empty())
		{
			auto state = std::move(queue.front());
			queue.pop();

			if (state.p + maxFlow * (TIME_P2 - state.t) < maxp)
			{
				continue;
			}

			uint64_t hash = state.t * 10000 + state.pos * 100 + state.posElephant;
			if (cache.find(hash) != cache.end())
			{
				if (cache.at(hash) >= state.p)
				{
					continue;
				}
				else
				{
					cache.at(hash) = state.p;
				}
			}
			cache.emplace(hash, state.p);

			if (state.p > maxp)
			{
				maxp = state.p;
			}

			if (state.t == TIME_P2)
			{
				continue;
			}

			// Do nothing until end
			{
				State2 newState{ state };
				newState.t = TIME_P2;
				newState.p += (TIME_P2 - state.t) * newState.rate;

				queue.push(newState);
			}


			if ((state.valves & 1ll << state.pos) == 0 && flowValues.at(state.pos) > 0)
			{
				auto newState = openValve(state, flowValues, state.pos);
				++newState.t;

				for (auto& [otherValve, _] : edges.at(state.posElephant))
				{
					newState.posElephant = otherValve;
					queue.push(newState);
				}
			}

			if ((state.valves & 1ll << state.posElephant) == 0 && flowValues.at(state.posElephant) > 0)
			{
				auto newState = openValve(state, flowValues, state.posElephant);
				++newState.t;

				for (auto& [otherValve, _] : edges.at(state.pos))
				{
					newState.pos = otherValve;
					queue.push(newState);
				}
			}

			if ((state.valves & 1ll << state.pos) == 0 && flowValues.at(state.pos) > 0 && (state.valves & 1ll << state.posElephant) == 0
				&& flowValues.at(state.posElephant) > 0)
			{
				State2 newState{ state };
				++newState.t;
				newState.valves |= 1ll << state.pos;
				newState.valves |= 1ll << state.posElephant;
				newState.rate = 0;
				for (auto v = 0; v < flowValues.size(); ++v)
				{
					if (newState.valves & (1ll << v))
					{
						newState.rate += flowValues.at(v);
					}
				}
				newState.p += newState.rate;
				queue.push(newState);
			}

			for (auto& [otherValve, _] : edges.at(state.pos))
			{
				for (auto& [otherElephantValve, _] : edges.at(state.posElephant))
				{
					State2 newState{ state };
					newState.t += 1;
					newState.pos = otherValve;
					newState.posElephant = otherElephantValve;

					newState.p += newState.rate;

					queue.push(newState);
				}
			}
		}

		return maxp;
	}
}

AOC_DAY_REPS(16, 1)(const std::string& input)
{
	FlowValues flowValues;
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

	EdgeList edges;
	EdgeList edges2;

	for (auto& [valve, _] : tunnels)
	{
		std::unordered_set<std::string> seen{};
		edges.emplace(names.at(valve), findEdges(valve, tunnels, flowValues, names, seen));

		std::vector<std::pair<int, int>> v;
		for (auto& t : tunnels.at(valve))
		{
			v.emplace_back(names.at(t), 1);
		}
		edges2.emplace(names.at(valve), v);
	}

	auto p1 = part1(edges, flowValues, names.at("AA"));
	auto p2 = part2(edges2, flowValues, names.at("AA"));

	return { p1, p2 };
}