const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day9.txt",
    .solve = &solve,
    .benchmarkIterations = 5,
} };

const FileEntry = struct { type: enum { File, Space }, id: u32, size: usize };
const FileEntryList = std.DoublyLinkedList(FileEntry);

fn solve(_: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var buffer: [10 * 20000]u32 = undefined;

    var cursorBack: usize = 0;
    var parsingFile = true;
    var file: u32 = 1; // NOTE: ALL FILES ARE ACTUALLY 1 LOWER, BUT LIKE THIS WE CAN USE 0 TO INDICATE NOTHING
    for (data) |c| {
        const num = c - '0';
        for (0..num) |i| {
            buffer[cursorBack + i] = if (parsingFile) file else 0;
        }
        cursorBack += num;
        if (parsingFile) file += 1;
        parsingFile = !parsingFile;
    }
    const length = cursorBack;

    var cursorFront: usize = 0;
    cursorBack = length - 1;
    while (cursorFront < cursorBack) {
        while (buffer[cursorFront] != 0) cursorFront += 1;
        while (cursorFront < cursorBack and buffer[cursorBack] == 0) cursorBack -= 1;

        if (cursorFront < cursorBack) {
            buffer[cursorFront] = buffer[cursorBack];
            cursorFront += 1;
            cursorBack -= 1;
        }
    }

    var allocBuffer: [30000]std.DoublyLinkedList(FileEntry).Node = undefined;
    var allocPtr: usize = 0;

    var list = FileEntryList{};
    file = 0;
    parsingFile = true;
    for (data) |c| {
        allocBuffer[allocPtr] = .{ .data = .{
            .type = if (parsingFile) .File else .Space,
            .id = file,
            .size = c - '0',
        } };
        if (parsingFile) file += 1;
        parsingFile = !parsingFile;

        list.append(&allocBuffer[allocPtr]);
        allocPtr += 1;
    }

    var listCursorBack = list.last;
    while (listCursorBack) |fileEntry| : (listCursorBack = fileEntry.prev) {
        if (fileEntry.data.type != .File) continue;

        var itFront = list.first;
        while (itFront) |node| : (itFront = node.next) {
            if (node == fileEntry) {
                // Don't look beyond where we came from
                itFront = null;
                break;
            }
            if (node.data.type != .Space) continue;
            if (node.data.size < fileEntry.data.size) continue;

            break;
        }

        if (itFront) |openSpace| {
            // Found open space to move to!

            // Create new entry
            allocBuffer[allocPtr] = .{ .data = fileEntry.data };
            list.insertBefore(openSpace, &allocBuffer[allocPtr]);
            allocPtr += 1;
            fileEntry.data.type = .Space; // Set old entry to be open space
            openSpace.data.size -= fileEntry.data.size; // Reduce open space we placed the entry in by entry size
        }
    }

    return .{
        .p1 = .{ .i = checksum(buffer[0..(cursorBack + 1)]) },
        .p2 = .{ .i = checksumList(list) },
    };
}

fn printList(list: FileEntryList) void {
    var it = list.first;
    while (it) |node| : (it = node.next) {
        for (0..node.data.size) |_| {
            if (node.data.type == .Space) {
                std.debug.print(".", .{});
            } else {
                std.debug.print("{}", .{node.data.id});
            }
        }
    }
    std.debug.print("\n", .{});
}

fn checksum(buffer: []const u32) u64 {
    var result: u64 = 0;
    for (buffer, 0..) |f, i| {
        result += (f - 1) * i;
    }
    return result;
}

fn checksumList(list: FileEntryList) u64 {
    var result: u64 = 0;
    var i: usize = 0;
    var it = list.first;
    while (it) |entry| : (it = entry.next) {
        if (entry.data.type == .File) {
            for (i..(i + entry.data.size)) |bi| {
                result += bi * entry.data.id;
            }
        }
        i += entry.data.size;
    }
    return result;
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\2333133121414131402
    );
    try std.testing.expectEqual(1928, result.p1.i);
    try std.testing.expectEqual(2858, result.p2.i);
}
