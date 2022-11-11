#include "aoc.h"

#include <chrono>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <optional>

const auto BENCHMARK_ITERATIONS = 100;

namespace aoc
{
	std::map<int, std::unique_ptr<Solver>> solvers;

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

	void SolveAll()
	{
		const auto size = solvers.size();

		std::cout << "Solving " << size << " days:" << std::endl << std::endl;

		auto totalDuration = std::chrono::nanoseconds::zero();

		for (int day = 0; day < size * 2; day++)
		{
			if (solvers.find(day) != solvers.end())
			{
				auto input = ReadInput(day);
				auto inputStr = input.value_or("");

				auto& solver = solvers.at(day);

				auto solution = solver->Solve(input.value_or(""));

				std::cout << "Solving day " << day << "... " << (input.has_value() ? "" : "(no input)") << std::endl;

				auto start = std::chrono::high_resolution_clock::now();
				for (auto i = 0; i < BENCHMARK_ITERATIONS; i++)
				{
					solver->Solve(inputStr);
				}
				auto duration = (std::chrono::high_resolution_clock::now() - start) / BENCHMARK_ITERATIONS;
				totalDuration += duration;

				std::cout << "    Solution p1: " << solution.first << std::endl;
				std::cout << "    Solution p2: " << solution.second << std::endl;
				std::cout << "  time: " << DisplayTime(duration) << "ms" << std::endl;

				std::cout << std::endl;
			}
		}

		std::cout << "Total time: " << DisplayTime(totalDuration) << "ms" << std::endl;
	}
}
