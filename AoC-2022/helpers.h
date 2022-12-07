#pragma once

#include <functional>
#include <sstream>

void ForEachLine(const std::string& s, std::function<void(const std::string_view&)> handler);
