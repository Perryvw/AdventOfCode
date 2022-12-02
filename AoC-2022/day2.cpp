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

uint32_t Outcome(char opponentPlay, char selfPlay)
{
	if (selfPlay == SELF_ROCK)
	{
		if (opponentPlay == OPP_ROCK) return 3;
		if (opponentPlay == OPP_PAPER) return 0;
		if (opponentPlay == OPP_SCISSORS) return 6;
	}
	if (selfPlay == SELF_PAPER)
	{
		if (opponentPlay == OPP_ROCK) return 6;
		if (opponentPlay == OPP_PAPER) return 3;
		if (opponentPlay == OPP_SCISSORS) return 0;
	}
	if (selfPlay == SELF_SCISSORS)
	{
		if (opponentPlay == OPP_ROCK) return 0;
		if (opponentPlay == OPP_PAPER) return 6;
		if (opponentPlay == OPP_SCISSORS) return 3;
	}

	throw std::logic_error{ "Unknown round" };
}

char Strategy(char opponentPlay, char desiredResult)
{
	if (opponentPlay == OPP_ROCK)
	{
		if (desiredResult == RESULT_LOSE) return SELF_SCISSORS;
		if (desiredResult == RESULT_DRAW) return SELF_ROCK;
		if (desiredResult == RESULT_WIN) return SELF_PAPER;
	}
	if (opponentPlay == OPP_PAPER)
	{
		if (desiredResult == RESULT_LOSE) return SELF_ROCK;
		if (desiredResult == RESULT_DRAW) return SELF_PAPER;
		if (desiredResult == RESULT_WIN) return SELF_SCISSORS;
	}
	if (opponentPlay == OPP_SCISSORS)
	{
		if (desiredResult == RESULT_LOSE) return SELF_PAPER;
		if (desiredResult == RESULT_DRAW) return SELF_SCISSORS;
		if (desiredResult == RESULT_WIN) return SELF_ROCK;
	}

	throw std::logic_error{ "Unknown round strategy" };
}


AOC_DAY(2)(const std::string& input)
{
	std::stringstream ss{ input };
	std::string line;

	uint32_t total = 0;
	uint32_t total2 = 0;

	while (std::getline(ss, line))
	{
		total += Points(line[2]) + Outcome(line[0], line[2]);
		total2 += Points(Strategy(line[0], line[2])) + PointsResult(line[2]);
	}

	return { total, total2 };
}