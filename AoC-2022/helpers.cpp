#include "helpers.h"

int parseInt(std::string_view s)
{
	char* end;
	return strtol(s.data(), &end, 10);
}
