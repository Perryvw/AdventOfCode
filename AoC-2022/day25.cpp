#include "aoc.h"
#include "helpers.h"

#include <numeric>

namespace
{
	int mapDigit(char c)
	{
		switch (c)
		{
		case '2':
			return 2;
		case '1':
			return 1;
		case '0':
			return 0;
		case '-':
			return -1;
		case '=':
			return -2;
		}
	}

	int64_t decode(std::string_view snafu)
	{
		int64_t val = 0;
		for (auto c : snafu)
		{
			val = val * 5 + mapDigit(c);
		}
		return val;
	}

	std::string encode(int64_t v)
	{
		std::string result;
		while (v > 0)
		{
			auto r = v % 5;
			switch (r) {
			case 0: result = "0" + result;break;
			case 1: result = "1" + result;break;
			case 2: result = "2" + result;break;
			case 3: result = "=" + result; v += 2; break;
			case 4: result = "-" + result; v += 1; break;

			}
			v /= 5;
		}
		return result;
	}
}

AOC_DAY(25)(const std::string& input)
{
	auto p1 = 0;
	auto p2 = 0;

	std::vector<int64_t> fuelNrs;

	ForEachLine(input, [&](std::string_view line) { fuelNrs.emplace_back(decode(line)); });

	auto sum = std::accumulate(fuelNrs.begin(), fuelNrs.end(), 0ll);

	return { encode(sum), 0};
}