#include "helpers.h"

void ForEachLine(const std::string& s, std::function<void(const std::string_view&)> handler)
{
	std::istringstream ss{ s };
	std::string line;

	while (std::getline(ss, line))
	{
		handler(std::string_view{line});
	}
}