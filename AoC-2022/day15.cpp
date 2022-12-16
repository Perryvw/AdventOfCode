#include "aoc.h"
#include "helpers.h"

#include <algorithm>

namespace
{
	constexpr auto P1_ROW = 2000000;
	constexpr auto P2_BOUNDS = 4000000;

	struct Position {
		int x;
		int y;
	};

	struct Sensor {
		Position pos;
		Position closestBeacon;
		int closestDistance;
	};

	int distance(int x, int y, const Position& to) { return std::abs(x - to.x) + std::abs(y - to.y); }
	int distance(const Position& from, const Position& to) { return distance(from.x, from.y, to); }

	bool insideEnvelope(int x, int y, const Sensor& s) { return distance(x, y, s.pos) <= s.closestDistance; }
	bool insideEnvelope(const Position& p, const Sensor& s) { return insideEnvelope(p.x, p.y, s); }

	bool isRegionInsideEnvelope(const Position& regionMin, const Position& regionMax, const Sensor& s)
	{
		return insideEnvelope(regionMin, s) && insideEnvelope(regionMax, s) && insideEnvelope(regionMin.x, regionMax.y, s)
			   && insideEnvelope(regionMax.x, regionMin.y, s);
	}

	int part1(const std::vector<Sensor>& sensors, int minx, int maxx)
	{
		Position regionMin{ minx, P1_ROW };
		Position regionMax{ maxx, P1_ROW };
		auto beaconFree =
			std::any_of(sensors.begin(), sensors.end(), [&](const Sensor& s) { return isRegionInsideEnvelope(regionMin, regionMax, s) && (s.closestBeacon.y != P1_ROW || (s.closestBeacon.x != minx && s.closestBeacon.x != maxx)) ; });

		if (beaconFree)
		{
			return maxx - minx + 1;
		}
		else if (minx == maxx)
		{
			return 0;
		}
		else if (maxx - minx == 1)
		{
			return part1(sensors, minx, minx) + part1(sensors, maxx, maxx);
		}
		else
		{
			auto half = (maxx + minx) / 2;
			return part1(sensors, minx, half - 1) + part1(sensors, half, maxx);
		}
	}

	std::optional<uint64_t> part2_rec(const std::vector<Sensor>& sensors, Position regionMin, Position regionMax)
	{
		auto beaconFree =
			std::any_of(sensors.begin(), sensors.end(), [&](const Sensor& s) { return isRegionInsideEnvelope(regionMin, regionMax, s); });

		if (!beaconFree)
		{
			if (regionMin.x == regionMax.x && regionMin.y == regionMax.y)
			{
				return static_cast<uint64_t>(regionMax.x) * 4000000 + regionMax.y;
			}

			if (regionMax.x - regionMin.x <= 1 && regionMax.y - regionMin.y <= 1)
			{
				auto q1 = part2_rec(sensors, regionMin, regionMin);
				if (q1.has_value())
					return q1;

				auto q2 = part2_rec(sensors, { regionMin.x, regionMax.y }, { regionMin.x, regionMax.y });
				if (q2.has_value())
					return q2;

				auto q3 = part2_rec(sensors, { regionMax.x, regionMin.y }, { regionMax.x, regionMin.y });
				if (q3.has_value())
					return q3;

				auto q4 = part2_rec(sensors, regionMax, regionMax);
				return q4;
			}

			auto halfx = (regionMax.x + regionMin.x) / 2;
			auto halfy = (regionMax.y + regionMin.y) / 2;

			auto q1 = part2_rec(sensors, regionMin, { std::max(regionMin.x, halfx - 1), std::max(regionMin.y, halfy - 1) });
			if (q1.has_value())
				return q1;

			auto q2 = part2_rec(sensors, { regionMin.x, halfy }, { std::max(regionMin.x, halfx - 1), regionMax.y });
			if (q2.has_value())
				return q2;

			auto q3 = part2_rec(sensors, { halfx, regionMin.y }, { regionMax.x, std::max(regionMin.y, halfy - 1) });
			if (q3.has_value())
				return q3;

			auto q4 = part2_rec(sensors, { halfx, halfy }, regionMax);
			return q4;
		}
		else
		{
			return std::nullopt;
		}
	}

	uint64_t part2(const std::vector<Sensor>& sensors)
	{
		Position regionMin{ 0, 0 };
		Position regionMax{ P2_BOUNDS, P2_BOUNDS };

		return *part2_rec(sensors, regionMin, regionMax);
	}
}

AOC_DAY_REPS(15, 5)(const std::string& input)
{
	std::vector<Sensor> sensors;

	ForEachLine(input, [&](std::string_view line) {
		Sensor s{};

		char* end;
		s.pos.x = strtol(line.data() + 12, &end, 10);
		s.pos.y = strtol(end + 4, &end, 10);
		s.closestBeacon.x = strtol(end + 25, &end, 10);
		s.closestBeacon.y = strtol(end + 4, &end, 10);

		s.closestDistance = distance(s.pos, s.closestBeacon);

		sensors.emplace_back(std::move(s));
	});

	auto minx = sensors[0].pos.x - sensors[0].closestDistance;
	auto maxx = sensors[0].pos.x + sensors[0].closestDistance;

	for (auto& s : sensors)
	{
		minx = std::min(minx, s.pos.x - s.closestDistance);
		maxx = std::max(maxx, s.pos.x + s.closestDistance);
	}

	return { part1(sensors, minx, maxx), part2(sensors) };
}