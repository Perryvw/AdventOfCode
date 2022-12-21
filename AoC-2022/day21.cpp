#include "aoc.h"
#include "helpers.h"

#include <unordered_map>

namespace
{
	struct MonkeyOperation {
		std::string lhs;
		char op;
		std::string rhs;
	};
	using MonkeyDo = std::variant<int64_t, MonkeyOperation>;
	using MonkeyMap = std::unordered_map<std::string, MonkeyDo>;

	int64_t evaluate(const MonkeyDo& monkey, const MonkeyMap& monkeys)
	{
		if (std::holds_alternative<int64_t>(monkey))
		{
			return std::get<int64_t>(monkey);
		}
		else
		{
			auto& operation = std::get<MonkeyOperation>(monkey);
			auto lhs = evaluate(monkeys.at(operation.lhs), monkeys);
			auto rhs = evaluate(monkeys.at(operation.rhs), monkeys);

			if (operation.op == '+')
				return lhs + rhs;
			else if (operation.op == '-')
				return lhs - rhs;
			else if (operation.op == '*')
				return lhs * rhs;
			else if (operation.op == '/')
				return lhs / rhs;
			else
				throw std::logic_error{ "unexpected operator" };
		}
	}

	char inverseOperator(char op)
	{
		switch (op)
		{
		case '+':
			return '-';
		case '-':
			return '+';
		case '*':
			return '/';
		case '/':
			return '*';
		}
		throw std::logic_error("unknown operaotr");
	}

	void solveFor(const std::string& variable, std::unordered_map<std::string, std::string>& usedBy, MonkeyMap& monkeys)
	{
		auto& usedByVar = usedBy.at(variable);
		auto& containingOperation = std::get<MonkeyOperation>(monkeys.at(usedByVar));

		if (usedByVar == "root")
		{
			monkeys.at(variable) = containingOperation.lhs == variable 
				? evaluate(monkeys.at(containingOperation.rhs), monkeys)
				: evaluate(monkeys.at(containingOperation.lhs), monkeys);
			return;
		}

		if (containingOperation.lhs == variable)
		{
			monkeys.at(variable) = MonkeyOperation{ usedByVar, inverseOperator(containingOperation.op), containingOperation.rhs };
		}
		else
		{
			if (containingOperation.op == '+' || containingOperation.op == '*')
			{
				monkeys.at(variable) = MonkeyOperation{ usedByVar, inverseOperator(containingOperation.op), containingOperation.lhs };
			}
			else
			{
				monkeys.at(variable) = MonkeyOperation{ containingOperation.lhs, containingOperation.op, usedByVar };
			}
		}

		solveFor(usedByVar, usedBy, monkeys);
	}
}

AOC_DAY(21)(const std::string& input)
{
	MonkeyMap monkeys;
	std::unordered_map<std::string, std::string> usedBy;

	ForEachLine(input, [&](std::string_view line) {
		auto name = line.substr(0, 4);

		if (std::isdigit(line[6]))
		{
			monkeys.emplace(name, parseInt(line.substr(6)));
		}
		else
		{
			std::string lhs{ line.substr(6, 4) };
			std::string rhs{ line.substr(13, 4) };
			monkeys.emplace(name, MonkeyOperation{ lhs, line[11], rhs });
			usedBy.emplace(lhs, name);
			usedBy.emplace(rhs, name);
		}
	});

	auto p1 = evaluate(monkeys.at("root"), monkeys);

	auto& root = std::get<MonkeyOperation>(monkeys.at("root"));
	monkeys.at("root") = MonkeyOperation{ root.lhs, '=', root.rhs };

	solveFor("humn", usedBy, monkeys);

	auto p2 = evaluate(monkeys.at("humn"), monkeys);

	return { static_cast<size_t>(p1), static_cast<size_t>(p2) };
}