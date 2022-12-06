#include "aoc.h"

#include <array>
#include <sstream>
#include <vector>

namespace
{
	auto part1(const std::string& buffer, int markerLength)
	{
		size_t markerStart = 0;

		size_t result = 0;

		for (int i = 0; i < buffer.length() - 1; i++)
		{
			auto prevPos = std::string_view{ buffer.data() + markerStart, i + 1 - markerStart }.find(buffer[i + 1]);
			if (prevPos != std::string::npos)
			{
				markerStart += prevPos + 1;
			}

			// Count start and current index too, so +2
			if (i - markerStart + 2 == markerLength)
			{
				result = i + 2;
				break;
			}
		}

		return result;
	}
}

AOC_DAY(6)(const std::string& input) { return { part1(input, 4), part1(input, 14) }; }