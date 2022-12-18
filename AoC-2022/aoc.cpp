#include "aoc.h"

#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>

const auto BENCHMARK_ITERATIONS = 1000;

namespace aoc
{
	std::map<int, std::pair<std::unique_ptr<Solver>, bool>> solvers;

	double DisplayTime(const std::chrono::nanoseconds& ns)
	{
		auto ms = ns.count() / 1000000.0;
		return std::round(ms * 1000.0) / 1000.0;
	}

	std::optional<std::string> ReadInput(int day)
	{
		auto filename = "day" + std::to_string(day) + ".inp";

		if (std::filesystem::exists(filename))
		{
			std::ifstream fs{ filename };
			std::stringstream ss;
			ss << fs.rdbuf();
			return ss.str();
		}
		else
		{
			return std::nullopt;
		}
	}

	std::string AnswerString(Answer a)
	{
		if (std::holds_alternative<int>(a))
			return std::to_string(std::get<int>(a));
		else if (std::holds_alternative<size_t>(a))
			return std::to_string(std::get<size_t>(a));
		else
			return std::get<std::string>(a);
	}

	void SolveAll()
	{
		const auto size = solvers.size();

		std::cout << "Solving " << size << " days:" << std::endl << std::endl;

		auto totalDuration = std::chrono::nanoseconds::zero();

		bool anyFocus = std::any_of(solvers.begin(), solvers.end(), [](auto& p) { return p.second.second; });

		for (int day = 0; day < size * 2; day++)
		{
			if (solvers.find(day) != solvers.end())
			{
				auto& [solver, focus] = solvers.at(day);

				if (anyFocus && !focus)
				{
					std::cout << "Skipping not-focussed day " << day << std::endl;
					continue;
				}

				auto input = ReadInput(day);
				auto inputStr = input.value_or("");

				std::cout << "Solving day " << day << "... " << (input.has_value() ? "" : "(no input)") << std::endl;

				auto start = std::chrono::high_resolution_clock::now();
				auto solution = solver->Solve(input.value_or(""));

#if _DEBUG
				auto duration = (std::chrono::high_resolution_clock::now() - start);
#else
				auto iterations = solver->benchmarkRepetitions.value_or(BENCHMARK_ITERATIONS);
				std::cout << "(" << iterations << " iterations)" << std::endl;
				start = std::chrono::high_resolution_clock::now();
				for (unsigned int i = 0; i < iterations; i++)
				{
					solver->Solve(inputStr);
				}
				auto duration = (std::chrono::high_resolution_clock::now() - start) / iterations;
#endif _DEBUG
				totalDuration += duration;

				std::cout << "    Solution p1: " << AnswerString(solution.first) << std::endl;
				std::cout << "    Solution p2: " << AnswerString(solution.second) << std::endl;
				std::cout << "  time: " << DisplayTime(duration) << "ms" << std::endl;

				std::cout << std::endl;
			}
		}

		std::cout << "Total time: " << DisplayTime(totalDuration) << "ms" << std::endl;
	}
}
