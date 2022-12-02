#include "aoc.h"

#include <sstream>

constexpr auto OPP_ROCK = 'A';
constexpr auto OPP_PAPER = 'B';
constexpr auto OPP_SCISSORS = 'C';

constexpr auto SELF_ROCK = 'X';
constexpr auto SELF_PAPER = 'Y';
constexpr auto SELF_SCISSORS = 'Z';

constexpr auto RESULT_LOSE = 'X';
constexpr auto RESULT_DRAW = 'Y';
constexpr auto RESULT_WIN = 'Z';

uint32_t Points(char play)
{
	switch (play) {
	case SELF_ROCK: return 1;
	case SELF_PAPER: return 2;
	case SELF_SCISSORS: return 3;
	default: throw std::logic_error{ "Unknown play: " + play };
	}
}

uint32_t PointsResult(char play)
{
	switch (play) {
	case RESULT_LOSE: return 0;
	case RESULT_DRAW: return 3;
	case RESULT_WIN: return 6;
	default: throw std::logic_error{ "Unknown result: " + play };
	}
}

auto OutcomeSequence(int index)
{
	return 1 - (index % 3);
}

auto OutcomeOffset(int index)
{
	return (4 - index) % 3;
}

auto Outcome(char opponentPlay, char selfPlay)
{
	return 3 + 3 * OutcomeSequence(OutcomeOffset(selfPlay - SELF_ROCK) + opponentPlay - OPP_ROCK);
}

auto Strategy(char opponentPlay, char desiredResult)
{
	return (opponentPlay - OPP_ROCK + desiredResult - RESULT_LOSE + 2) % 3;
}


AOC_DAY(2)(const std::string& input)
{
	std::stringstream ss{ input };
	std::string line;

	int total = 0;
	int total2 = 0;

	while (std::getline(ss, line))
	{
		total += Points(line[2]) + Outcome(line[0], line[2]);
		total2 += 1 + Strategy(line[0], line[2]) + PointsResult(line[2]);
	}

	return { total, total2 };
}