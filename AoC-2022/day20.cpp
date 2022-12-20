#include "aoc.h"
#include "helpers.h"

#include <list>
#include <vector>

namespace
{
	class RingBuffer
	{
	public:
		struct Node {
			Node* previous;
			Node* next;
			int value;
		};

		RingBuffer() { nodes.reserve(10000); }

		Node& emplace_back(int v)
		{
			if (nodes.size() == 0)
			{
				nodes.emplace_back(Node{ nullptr, nullptr, v });
				auto& l = last();
				l.next = &l;
				l.previous = &l;
			}
			else
			{
				auto& lastNode = last();
				auto& nextNode = *lastNode.next;

				nodes.emplace_back(Node{ &lastNode, &nextNode, v });

				lastNode.next = &last();
				nextNode.previous = &last();
			}
			return last();
		}

		Node* move(RingBuffer::Node* n, int amount)
		{
			auto offset = amount % static_cast<int>(size());
			if (offset < 0)
				offset += size() - 1;
			for (int x = 0; x < offset; ++x)
			{
				n = n->next;
			}
			return n;
		}

		Node& first() { return nodes.at(0); }
		Node& last() { return nodes.at(nodes.size() - 1); }

		const size_t size() { return nodes.size(); }
		std::vector<Node>& insertOrder() { return nodes; }

	private:
		std::vector<Node> nodes;
	};

	void print(RingBuffer& rb)
	{
		auto* start = &rb.first();
		auto* it = start;
		auto c = 0;
		do
		{
			c++;
			std::cout << it->value << ", ";
			it = it->next;
		} while (it->next != start);
		std::cout << it->value << std::endl;
		c++;
		std::cout << c << "/" << rb.size() << std::endl;
	}
}

FOCUS_AOC_DAY(20)(const std::string& input)
{
	RingBuffer ringbuffer;

	ForEachLine(input, [&](std::string_view line) { ringbuffer.emplace_back(parseInt(line)); });

	// print(ringbuffer);

	for (auto& n : ringbuffer.insertOrder())
	{
		auto offset = n.value % static_cast<int>(ringbuffer.size());
		auto* moveAfter = ringbuffer.move(&n, offset);

		if (moveAfter == &n)
			continue;

		auto* currentBefore = n.previous;
		auto* currentAfter = n.next;
		currentBefore->next = currentAfter;
		currentAfter->previous = currentBefore;

		auto* nextBefore = moveAfter;
		auto* nextAfter = nextBefore->next;

		nextBefore->next = &n;
		nextAfter->previous = &n;

		n.previous = nextBefore;
		n.next = nextAfter;

		// print(ringbuffer);
	}

	auto& zero =
		*std::find_if(ringbuffer.insertOrder().begin(), ringbuffer.insertOrder().end(), [](const auto& n) { return n.value == 0; });
	auto* c1 = ringbuffer.move(&zero, 1000);
	auto* c2 = ringbuffer.move(c1, 1000);
	auto* c3 = ringbuffer.move(c2, 1000);

	print(ringbuffer);

	std::cout << c1->value << std::endl;
	std::cout << c2->value << std::endl;
	std::cout << c3->value << std::endl;

	return { c1->value + c2->value + c3->value, 0 };
}