#pragma once

#include <functional>
#include <string_view>

template <typename TFunc> void ForEachLine(const std::string& s, const TFunc& handler)
{
	size_t lineStart = 0;
	size_t i = 0;
	for (; i < s.length(); ++i)
	{
		if (s[i] == '\r')
		{
			handler(std::string_view{ s.data() + lineStart, i - lineStart });
			lineStart = i + 2;
			i++;
			continue;
		}
		else if (s[i] == '\n')
		{
			handler(std::string_view{ s.data() + lineStart, i - lineStart });
			lineStart = i + 1;
		}
	}
	handler(std::string_view{ s.data() + lineStart, i - lineStart });
}

int parseInt(std::string_view s);

int posmod(int v, int m);
int64_t posmod(int64_t v, int64_t m);

struct Point {
	int x;
	int y;

	bool operator==(const Point& other) const noexcept { return other.x == x && other.y == y; }
};

template <> struct std::hash<Point> {
	std::size_t operator()(const Point& p) const noexcept { return (static_cast<size_t>(p.x) << 32) | p.y; }
};
