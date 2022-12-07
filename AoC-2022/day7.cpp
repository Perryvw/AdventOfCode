#include "aoc.h"

#include <filesystem>
#include <functional>
#include <string_view>
#include <unordered_map>

#include "helpers.h"

namespace
{
	struct FileSystemEntry {
		bool isDirectory;
		long size;
		FileSystemEntry* parent;
		std::unordered_map<std::string, FileSystemEntry> children;
	};

	long directorySize(const FileSystemEntry& directory)
	{
		long size = 0;
		for (auto& [_, child] : directory.children)
		{
			if (child.isDirectory)
				size += directorySize(child);
			else
				size += child.size;
		}

		return size;
	}

	template <typename TFunc> void walkDirectories(const FileSystemEntry& directory, const TFunc& handler)
	{
		handler(directory);
		for (auto& [_, child] : directory.children)
		{
			if (child.isDirectory)
			{
				walkDirectories(child, handler);
			}
		}
	}

	long part1(const FileSystemEntry& root)
	{
		long p1 = 0;

		walkDirectories(root, [&](const FileSystemEntry& dir) {
			auto size = directorySize(dir);
			if (size <= 100000)
			{
				p1 += size;
			}
		});

		return p1;
	}

	long part2(const FileSystemEntry& root)
	{
		auto usedSpace = directorySize(root.children.begin()->second);
		auto requiredSpace = usedSpace - 40000000;

		auto dirToDeleteSize = 70000000;

		walkDirectories(root, [&](const FileSystemEntry& dir) {
			auto size = directorySize(dir);
			if (size >= requiredSpace && size < dirToDeleteSize)
			{
				dirToDeleteSize = size;
			}
		});

		return dirToDeleteSize;
	}
}

AOC_DAY(7)(const std::string& input)
{
	FileSystemEntry root{ true, 0, nullptr, {} };
	FileSystemEntry* currentDir = &root;

	ForEachLine(input, [&](auto line) {
		if (line[0] == '$' && line[2] == 'c' && line[5] == '.')
		{
			currentDir = currentDir->parent;
		}
		else if (line[0] == '$' && line[2] == 'c')
		{
			auto name = std::string{ line.substr(5) };
			if (currentDir->children.find(name) == currentDir->children.end())
			{
				currentDir->children.insert_or_assign(name, FileSystemEntry{ true, 0, currentDir, {} });
			}

			currentDir = &currentDir->children.at(name);
		}
		else if (line[0] != '$')
		{
			if (line[0] == 'd')
			{
				currentDir->children.insert_or_assign(std::string{ line.substr(4) }, FileSystemEntry{ true, 0, currentDir, {} });
			}
			else
			{
				char* lengthEnd;
				auto size = std::strtol(line.data(), &lengthEnd, 10);
				currentDir->children.insert_or_assign(std::string{ lengthEnd + 1 }, FileSystemEntry{ false, size, currentDir, {} });
			}
		}
	});

	return { part1(root), part2(root) };
}