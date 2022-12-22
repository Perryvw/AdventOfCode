#include "helpers.h"

int parseInt(std::string_view s)
{
	char* end;
	return strtol(s.data(), &end, 10);
}

int posmod(int v, int m)
{
	auto r = v % m;
	return r < 0 ? r + m : r;
}

int64_t posmod(int64_t v, int64_t m)
{
	auto r = v % m;
	return r < 0 ? r + m : r;
}
