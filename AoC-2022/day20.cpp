#include "aoc.h"
#include "helpers.h"

#include <list>
#include <vector>

namespace
{
	constexpr size_t DECODE_KEY = 811589153;

	template<typename T>
	class RingBuffer
	{
	public:
		struct Node {
			Node* previous;
			Node* next;
			T value;
		};

		RingBuffer() { nodes.reserve(10000); }

		Node& emplace_back(T v)
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

		Node* move(RingBuffer::Node* n, int64_t amount, int64_t m)
		{
			auto offset = amount % m;
			if (offset < 0)
				offset += m;
			for (int64_t x = 0; x < offset; ++x)
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

	template<typename T>
	void print(RingBuffer<T>& rb)
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

	template<typename T>
	void mix(RingBuffer<T>& ringbuffer)
	{
		for (auto& n : ringbuffer.insertOrder())
		{
			auto* moveAfter = ringbuffer.move(&n, n.value, ringbuffer.size() - 1);

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
		}
	}
}

AOC_DAY_REPS(20, 10)(const std::string& input)
{
	RingBuffer<int> ringbuffer;
	RingBuffer<int64_t> ringbufferP2;

	ForEachLine(input, [&](std::string_view line) {
		ringbuffer.emplace_back(parseInt(line));
		ringbufferP2.emplace_back(static_cast<int64_t>(parseInt(line)) * DECODE_KEY);
	});

	mix(ringbuffer);

	auto& zero =
		*std::find_if(ringbuffer.insertOrder().begin(), ringbuffer.insertOrder().end(), [](const auto& n) { return n.value == 0; });
	auto* c1 = ringbuffer.move(&zero, 1000, ringbuffer.size());
	auto* c2 = ringbuffer.move(c1, 1000, ringbuffer.size());
	auto* c3 = ringbuffer.move(c2, 1000, ringbuffer.size());

	auto p1 = c1->value + c2->value + c3->value;

	for (auto x = 0; x < 10; x++)
	{
		mix(ringbufferP2);
	}

	auto& zeroP2 =
		*std::find_if(ringbufferP2.insertOrder().begin(), ringbufferP2.insertOrder().end(), [](const auto& n) { return n.value == 0; });
	auto* c1P2 = ringbufferP2.move(&zeroP2, 1000, ringbufferP2.size());
	auto* c2P2 = ringbufferP2.move(c1P2, 1000, ringbufferP2.size());
	auto* c3P2 = ringbufferP2.move(c2P2, 1000, ringbufferP2.size());

	auto p2 = c1P2->value + c2P2->value + c3P2->value;

	return { static_cast<size_t>(p1), static_cast<size_t>(p2) };
}