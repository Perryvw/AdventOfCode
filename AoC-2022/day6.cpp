#include "aoc.h"

#include <array>
#include <sstream>
#include <vector>

namespace
{
	auto part1(const std::string& buffer, int markerLength)
	{
		size_t markerStart = 0;
		size_t markerEnd = 0;

		size_t result = 0;

		for (int i = 0; i < buffer.length() - 1; i++)
		{
			auto prevPos = std::string_view{ buffer.data() + markerStart, markerEnd + 1 - markerStart }.find(buffer[i + 1]);
			if (prevPos != std::string::npos)
			{
				markerStart += prevPos + 1;
			}
			
			markerEnd++;

			if (1 + markerEnd - markerStart == markerLength)
			{
				result = markerEnd + 1;
				break;
			}
		}

		return result;
	}
}

AOC_DAY(6)(const std::string& input) { return { part1(input, 4), part1(input, 14) }; }