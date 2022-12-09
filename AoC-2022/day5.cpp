#include "aoc.h"

#include <stack>
#include <vector>

namespace
{

}

AOC_DAY(5)(const std::string& input)
{
	std::vector<std::string> stackLines{};

	std::vector<std::stack<char>> stacks{};
	std::vector<std::stack<char>> stacks2{};

	bool parsingStack = true;

	ForEachLine(input, [&](const std::string_view& line) {
		if (line.empty())
		{
			auto numStacks = (1 + stackLines[stackLines.size() - 1].length()) / 4;

			stacks.insert(stacks.end(), numStacks, {});

			for (auto stackLine = stackLines.rbegin() + 1; stackLine != stackLines.rend(); stackLine++)
			{
				for (int stackIdx = 0; stackIdx < numStacks; stackIdx++)
				{
					auto index = stackIdx * 4 + 1;
					if (stackLine->length() >= index && stackLine->at(index) != ' ')
					{
						stacks[stackIdx].push(stackLine->at(index));
					}
				}
			}

			stacks2 = stacks;

			parsingStack = false;
			return;
		}

		if (parsingStack)
		{
			stackLines.emplace_back(line);
		}
		else
		{
			auto amount = std::atoi(line.data() + 5);
			auto from = line[line.length() - 6] - '1';
			auto to = line[line.length() - 1] - '1';

			std::vector<char> p2stack{};

			for (auto i = 0; i < amount; i++)
			{
				stacks[to].push(stacks[from].top());
				stacks[from].pop();

				p2stack.emplace_back(stacks2[from].top());
				stacks2[from].pop();
			}

			for (auto it = p2stack.rbegin(); it != p2stack.rend(); it++)
			{
				stacks2[to].push(*it);
			}
		}
	});

	std::string p1;
	for (auto& stack : stacks)
	{
		p1 += stack.top();
	}

	std::string p2;
	for (auto& stack : stacks2)
	{
		p2 += stack.top();
	}

	return { p1, p2 };
}