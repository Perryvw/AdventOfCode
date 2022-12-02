#include "aoc.h"

#include <sstream>

constexpr auto OPP_ROCK = 'A';
constexpr auto SELF_ROCK = 'X';
constexpr auto RESULT_LOSE = 'X';

inline auto Points(char play)
{
	return play - 'W';
}

inline auto PointsResult(char play)
{
	return (play - RESULT_LOSE) * 3;
}

inline auto OutcomeSequence(int index)
{
	return 1 - (index % 3);
}

inline auto OutcomeOffset(int index)
{
	return (4 - index) % 3;
}

inline auto Outcome(char opponentPlay, char selfPlay)
{
	return 3 + 3 * OutcomeSequence(OutcomeOffset(selfPlay - SELF_ROCK) + opponentPlay - OPP_ROCK);
}

inline auto Strategy(char opponentPlay, char desiredResult)
{
	return (opponentPlay - OPP_ROCK + desiredResult - RESULT_LOSE + 2) % 3;
}

AOC_DAY(2)(const std::string& input)
{
	int total = 0;
	int total2 = 0;

	for (auto i = 0; i < input.length(); i += 4)
	{
		std::string_view line{ input.c_str() + i, 4 };
		total += Points(line[2]) + Outcome(line[0], line[2]);
		total2 += 1 + Strategy(line[0], line[2]) + PointsResult(line[2]);
	}

	return { total, total2 };
}