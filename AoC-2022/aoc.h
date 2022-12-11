#pragma once

#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <variant>

#include "helpers.h"

using Answer = std::variant<int, size_t, std::string>;
using Solution = std::pair<Answer, Answer>;

namespace aoc
{
	class Solver {
	public:
		virtual Solution Solve(const std::string& input) = 0;

		std::optional<uint32_t> benchmarkRepetitions;
	};

	extern std::map<int, std::pair<std::unique_ptr<Solver>, bool>> solvers;

	template<typename TSolver> requires std::is_base_of_v<Solver, TSolver>
	int AoCRegister(int n, bool focus, std::optional<uint32_t> repetitions = std::nullopt)
	{
		solvers.emplace(n, std::make_pair( std::make_unique<TSolver>(), focus ));
		solvers.at(n).first->benchmarkRepetitions = repetitions;
		return n;
	}

	void SolveAll();
}

#define AOC_DAY(day)                                                     \
class AOC_SOLUTION_DAY##day : public aoc::Solver {                       \
public:                                                                  \
	Solution Solve(const std::string& input) override;                   \
};                                                                       \
                                                                         \
const int _ = aoc::AoCRegister<AOC_SOLUTION_DAY##day>(day, false);       \
                                                                         \
Solution AOC_SOLUTION_DAY##day::Solve

#define AOC_DAY_REPS(day, repetitions)                                           \
class AOC_SOLUTION_DAY##day : public aoc::Solver {                               \
public:                                                                          \
	Solution Solve(const std::string& input) override;                           \
};                                                                               \
                                                                                 \
const int _ = aoc::AoCRegister<AOC_SOLUTION_DAY##day>(day, false, repetitions);  \
                                                                                 \
Solution AOC_SOLUTION_DAY##day::Solve

#define FOCUS_AOC_DAY(day)                                               \
class AOC_SOLUTION_DAY##day : public aoc::Solver {                       \
public:                                                                  \
	Solution Solve(const std::string& input) override;                   \
};                                                                       \
                                                                         \
const int _ = aoc::AoCRegister<AOC_SOLUTION_DAY##day>(day, true);        \
                                                                         \
Solution AOC_SOLUTION_DAY##day::Solve