#include "aoc.h"
#include "helpers.h"

#include <queue>
#include <unordered_set>

namespace
{
	struct Point3D {
		int x;
		int y;
		int z;
	};

	int hash(int x, int y, int z) { return (x << 16) + (y << 8) + z; }
	int hash(const Point3D& p) { return hash(p.x, p.y, p.z); }

	size_t part1(const std::vector<Point3D>& droplets)
	{
		std::unordered_set<int> seen;
		size_t surfaces = 0;

		for (auto& droplet : droplets)
		{
			surfaces += 6;
			seen.insert(hash(droplet));

			if (seen.contains(hash(droplet.x - 1, droplet.y, droplet.z)))
				surfaces -= 2;
			if (seen.contains(hash(droplet.x + 1, droplet.y, droplet.z)))
				surfaces -= 2;
			if (seen.contains(hash(droplet.x, droplet.y - 1, droplet.z)))
				surfaces -= 2;
			if (seen.contains(hash(droplet.x, droplet.y + 1, droplet.z)))
				surfaces -= 2;
			if (seen.contains(hash(droplet.x, droplet.y, droplet.z - 1)))
				surfaces -= 2;
			if (seen.contains(hash(droplet.x, droplet.y, droplet.z + 1)))
				surfaces -= 2;
		}

		return surfaces;
	}

	int part2(const std::vector<Point3D>& droplets)
	{
		std::unordered_set<int> dropletPositions;

		Point3D min = droplets[0];
		Point3D max = droplets[0];

		for (auto& droplet : droplets)
		{
			if (droplet.x < min.x)
				min.x = droplet.x;
			if (droplet.y < min.y)
				min.y = droplet.y;
			if (droplet.z < min.z)
				min.z = droplet.z;
			if (droplet.x > max.x)
				max.x = droplet.x;
			if (droplet.y > max.y)
				max.y = droplet.y;
			if (droplet.z > max.z)
				max.z = droplet.z;

			dropletPositions.insert(hash(droplet));
		}

		std::queue<Point3D> fill;
		fill.push({ min.x - 1, min.y - 1, min.z - 1 });

		int surfaces = 0;
		std::unordered_set<int> fillPositions;

		while (!fill.empty())
		{
			auto cell = fill.front();

			if (fillPositions.contains(hash(cell.x, cell.y, cell.z)))
			{
				fill.pop();
				continue;
			}

			surfaces += 6;
			fillPositions.insert(hash(cell));

			auto handleNeighbour = [&](int x, int y, int z) {
				auto h = hash(x, y, z);
				if (fillPositions.contains(h))
				{
					surfaces -= 2;
				}
				else if (x >= min.x - 1 && x <= max.x + 1 && y >= min.y - 1 && y <= max.y + 1 && z >= min.z - 1 && z <= max.z + 1
						 && !dropletPositions.contains(h))
				{
					fill.push({x, y, z});
				}
			};

			handleNeighbour(cell.x - 1, cell.y, cell.z);
			handleNeighbour(cell.x + 1, cell.y, cell.z);
			handleNeighbour(cell.x, cell.y - 1, cell.z);
			handleNeighbour(cell.x, cell.y + 1, cell.z);
			handleNeighbour(cell.x, cell.y, cell.z - 1);
			handleNeighbour(cell.x, cell.y, cell.z + 1);

			fill.pop();
		}

		auto outsideXLength = 3 + max.x - min.x;
		auto outsideYLength = 3 + max.y - min.y;
		auto outsideZLength = 3 + max.z - min.z;
		auto outsideSurface =
			2 * outsideXLength * outsideYLength + 2 * outsideXLength * outsideZLength + 2 * outsideYLength * outsideZLength;

		return surfaces - outsideSurface;
	}
}

AOC_DAY(18)(const std::string& input)
{
	std::vector<Point3D> droplets;

	ForEachLine(input, [&](std::string_view line) {
		char* end;
		auto x = strtol(line.data(), &end, 10);
		auto y = strtol(end + 1, &end, 10);
		auto z = strtol(end + 1, &end, 10);

		droplets.emplace_back(x, y, z);
	});

	return { part1(droplets), part2(droplets) };
}