#pragma once

#include <algorithm>
#include <iostream>
#include <map>
#include <memory>
#include <string>
#include <variant>

using Answer = std::variant<int, size_t, std::string>;
using Solution = std::pair<Answer, Answer>;

namespace aoc
{
	class Solver {
	public:
		virtual Solution Solve(const std::string& input) = 0;
	};

	extern std::map<int, std::unique_ptr<Solver>> solvers;

	template<typename TSolver> requires std::is_base_of_v<Solver, TSolver>
	int AoCRegister(int n)
	{
		solvers.emplace(n, std::make_unique<TSolver>());
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
const int _ = aoc::AoCRegister<AOC_SOLUTION_DAY##day>(day);              \
                                                                         \
Solution AOC_SOLUTION_DAY##day::Solve
