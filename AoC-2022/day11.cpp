#include "aoc.h"
#include "helpers.h"

#include <algorithm>
#include <deque>
#include <string>
#include <variant>

namespace
{
	constexpr auto NUM_ROUNDS_P1 = 20;
	constexpr auto NUM_ROUNDS_P2 = 10000;

	struct Monkey {
		int inspectCount;
		std::deque<uint64_t> items;
		char op;
		std::variant<char, int> operand;
		int testDivisibleBy;
		int ifTrue;
		int ifFalse;
	};

	uint64_t operate(const Monkey& monkey, uint64_t item)
	{
		if (monkey.op == '*')
		{
			if (std::holds_alternative<char>(monkey.operand))
			{
				return item * item;
			}
			else
			{
				return item * std::get<int>(monkey.operand);
			}
		}
		else if (monkey.op == '+')
		{
			if (std::holds_alternative<char>(monkey.operand))
			{
				return item + item;
			}
			else
			{
				return item + std::get<int>(monkey.operand);
			}
		}

		throw "unknown operator: " + std::string{ monkey.op };
	}

	uint64_t monkeyBusiness(const std::vector<Monkey>& monkeys)
	{
		std::vector<uint64_t> inspectCounts;
		std::transform(
			monkeys.begin(), monkeys.end(), std::back_inserter(inspectCounts), [](const Monkey& monkey) { return monkey.inspectCount; });
		std::sort(inspectCounts.begin(), inspectCounts.end());

		return inspectCounts[inspectCounts.size() - 1] * inspectCounts[inspectCounts.size() - 2];
	}

	uint64_t part1(std::vector<Monkey> monkeys)
	{
		for (auto round = 0; round < NUM_ROUNDS_P1; ++round)
		{
			for (auto& monkey : monkeys)
			{
				while (!monkey.items.empty())
				{
					++monkey.inspectCount;

					auto item = monkey.items.front();
					monkey.items.pop_front();

					auto worry = operate(monkey, item);
					worry = worry / 3;

					if (worry % monkey.testDivisibleBy == 0)
					{
						monkeys[monkey.ifTrue].items.push_back(worry);
					}
					else
					{
						monkeys[monkey.ifFalse].items.push_back(worry);
					}
				}
			}
		}

		return monkeyBusiness(monkeys);
	}

	uint64_t part2(std::vector<Monkey> monkeys)
	{
		uint64_t monkeymod = 1;
		for (auto& monkey : monkeys)
		{
			monkeymod *= monkey.testDivisibleBy;
		}

		for (auto round = 0; round < NUM_ROUNDS_P2; ++round)
		{
			for (auto& monkey : monkeys)
			{
				while (!monkey.items.empty())
				{
					++monkey.inspectCount;

					auto item = monkey.items.front();
					monkey.items.pop_front();

					auto worry = operate(monkey, item);
					worry = worry % monkeymod;

					if (worry % monkey.testDivisibleBy == 0)
					{
						monkeys[monkey.ifTrue].items.push_back(worry);
					}
					else
					{
						monkeys[monkey.ifFalse].items.push_back(worry);
					}
				}
			}
		}

		return monkeyBusiness(monkeys);
	}
}

AOC_DAY_REPS(11, 100)(const std::string& input)
{
	int lineIndex = 0;
	std::vector<Monkey> monkeys;

	ForEachLine(input, [&](const std::string_view& line) {
		auto lineLocal = lineIndex % 7;
		if (lineLocal == 0)
		{
			monkeys.emplace_back(Monkey{});
			lineIndex++;
			return;
		}

		auto& monkey = monkeys[lineIndex / 7];

		if (lineLocal == 1)
		{
			// items
			auto offset = 18;
			auto item = std::stol(line.data() + offset);
			while (item > 0)
			{
				monkey.items.push_back(item);
				offset += 3 + static_cast<int>(std::log10(item));
				if (offset >= line.length())
				{
					break;
				}
				item = std::stoi(line.data() + offset);
			}
		}
		else if (lineLocal == 2)
		{
			// operation
			monkey.op = line[23];
			if (line[25] == 'o')
			{
				monkey.operand = 'o';
			}
			else
			{
				monkey.operand = std::stoi(line.data() + 25);
			}
		}
		else if (lineLocal == 3)
		{
			// test
			monkey.testDivisibleBy = std::stoi(line.data() + 21);
		}
		else if (lineLocal == 4)
		{
			// if true
			monkey.ifTrue = std::stoi(line.data() + 29);
		}
		else if (lineLocal == 5)
		{
			// if false
			monkey.ifFalse = std::stoi(line.data() + 29);
		}

		++lineIndex;
	});

	std::vector<Monkey> monkeysp2 = monkeys;
	return { part1(std::move(monkeys)), part2(std::move(monkeysp2)) };
}