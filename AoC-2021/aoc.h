#pragma once

#include <any>
#include <functional>
#include <iostream>
#include <string>
#include <vector>

namespace AoC {

	struct Answer {
		virtual void compute() = 0;
		virtual void print() = 0;
	};

	std::unique_ptr<Answer> day1();
	std::unique_ptr<Answer> day2();
}

template<typename ...ArgTypes>
void log(ArgTypes const&... args) {
	((std::cout << args), ...);
	std::cout << std::endl;
}