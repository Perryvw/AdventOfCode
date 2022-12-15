#include "aoc.h"
#include "helpers.h"

#include <variant>

namespace
{
	enum class ComparisonResult
	{
		Right,
		Wrong,
		Undecided
	};

	struct Packet {
		std::vector<std::variant<int, Packet>> children;
	};

	Packet parsePacket(std::string_view str, int& offset)
	{
		Packet result{};

		offset++; // expect [

		while (str[offset] != ']')
		{
			if (str[offset] == ',')
			{
				offset++;
				continue;
			}
			else if (str[offset] == '[')
			{
				result.children.emplace_back(parsePacket(str, offset));
			}
			else
			{
				auto num = parseInt(str.substr(offset));
				result.children.emplace_back(num);
				if (num == 0)
				{
					++offset;
				}
				else
				{
					offset += std::floor(log10(num)) + 1;
				}
			}
		}

		offset++; // expect ]

		return result;
	}

	ComparisonResult compare(const Packet& p1, const Packet& p2)
	{
		for (auto i = 0; i < p1.children.size(); i++)
		{
			if (i > static_cast<int>(p2.children.size()) - 1)
			{
				return ComparisonResult::Wrong;
			}

			if (std::holds_alternative<int>(p1.children[i]) && std::holds_alternative<int>(p2.children[i]))
			{
				if (std::get<int>(p1.children[i]) < std::get<int>(p2.children[i]))
				{
					return ComparisonResult::Right;
				}
				else if (std::get<int>(p1.children[i]) > std::get<int>(p2.children[i]))
				{
					return ComparisonResult::Wrong;
				}
			}
			else if (std::holds_alternative<Packet>(p1.children[i]) && std::holds_alternative<Packet>(p2.children[i]))
			{
				auto r = compare(std::get<Packet>(p1.children[i]), std::get<Packet>(p2.children[i]));
				if (r != ComparisonResult::Undecided)
				{
					return r;
				}
			}
			else
			{
				if (std::holds_alternative<int>(p1.children[i]))
				{
					Packet np{};
					np.children.emplace_back(std::get<int>(p1.children[i]));
					auto r = compare(np, std::get<Packet>(p2.children[i]));
					if (r != ComparisonResult::Undecided)
					{
						return r;
					}
				}
				else
				{
					Packet np{};
					np.children.emplace_back(std::get<int>(p2.children[i]));
					auto r = compare(std::get<Packet>(p1.children[i]), np);
					if (r != ComparisonResult::Undecided)
					{
						return r;
					}
				}
			}
		}

		if (p1.children.size() < p2.children.size())
			return ComparisonResult::Right;

		return ComparisonResult::Undecided;
	}
}

AOC_DAY(13)(const std::string& input)
{
	std::vector<Packet> packets;

	ForEachLine(input, [&](std::string_view line) {
		if (!line.empty())
		{
			int offset = 0;
			packets.emplace_back(parsePacket(line, offset));
		}
	});

	auto p1 = 0;
	for (auto i = 0; i < packets.size(); i += 2)
	{
		if (compare(packets[i], packets[i + 1]) == ComparisonResult::Right)
		{
			p1 += (i / 2) + 1;
		}
	}

	Packet extraPacket1;
	extraPacket1.children.emplace_back(Packet{});
	std::get<Packet>(extraPacket1.children[0]).children.emplace_back(2);
	Packet extraPacket2;
	extraPacket2.children.emplace_back(Packet{});
	std::get<Packet>(extraPacket2.children[0]).children.emplace_back(6);

	auto ep1Spot = 1;
	auto ep2Spot = 2;

	for (auto& p : packets)
	{
		if (compare(p, extraPacket2) == ComparisonResult::Right)
		{
			ep2Spot++;

			if (compare(p, extraPacket1) == ComparisonResult::Right)
			{
				ep1Spot++;
			}
		}
	}

	return { p1, ep1Spot * ep2Spot };
}