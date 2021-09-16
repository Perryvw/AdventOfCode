// Entry point

#include <chrono>

#include "main.h"
#include "aoc.h"

using AnswerConstructor = std::function<std::unique_ptr<AoC::Answer>()>;

std::initializer_list<AnswerConstructor> focus = {
};

std::initializer_list<AnswerConstructor> days = {
	AoC::day1,
};

void benchmark(AnswerConstructor factory) {
	auto answer = factory();

	std::chrono::high_resolution_clock clock;
	auto start = clock.now();

	auto REPEAT_COUNT = 1000;

	for (auto i = 0; i < REPEAT_COUNT; ++i) {
		answer->compute();
	}

	auto end = clock.now();

	answer->print();

	auto durationNs = std::chrono::duration_cast<std::chrono::nanoseconds>(end - start).count() / REPEAT_COUNT;
	auto duration = static_cast<float>(durationNs) / 1000000;

	std::cout << std::endl << "Execution time: " << duration << "ms" << std::endl;
}

int main()
{
	if (focus.size() > 0) {
		for (const auto& f : focus) {
			benchmark(f);
		}
	}
	else {
		for (const auto& f : days) {
			benchmark(f);
		}
	}

	return 0;
}
