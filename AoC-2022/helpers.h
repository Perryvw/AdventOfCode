#pragma once

#include <functional>
#include <sstream>

template <typename TFunc> void ForEachLine(const std::string& s, const TFunc& handler)
{
	std::istringstream ss{ s };
	std::string line;

	while (std::getline(ss, line))
	{
		handler(std::string_view{ line });
	}
}
