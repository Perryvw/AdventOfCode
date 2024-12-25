const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day25.txt",
    .solve = &solve,
} };

const Lock = [5]u8;
const Key = [5]u8;

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    const p2: u64 = 0;

    var locks = std.ArrayList(Lock).init(allocator);
    defer locks.deinit();
    var keys = std.ArrayList(Key).init(allocator);
    defer keys.deinit();

    var schematics = std.mem.tokenizeSequence(u8, data, "\n\n");
    while (schematics.next()) |schematic| {
        const grid = common.ImmutableGrid.init(schematic);
        if (grid.isCharAtPosition(0, 0, '#')) {
            try locks.append(parseLock(&grid));
        } else {
            try keys.append(parseKey(&grid));
        }
    }

    for (locks.items) |lock| {
        for (keys.items) |key| {
            if (keyFitsLock(key, lock)) {
                p1 += 1;
            }
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn parseLock(grid: *const common.ImmutableGrid) Lock {
    var lock: Lock = undefined;
    for (0..5) |x| {
        for (1..7) |y| {
            if (!grid.isCharAtPosition(@intCast(x), @intCast(y), '#')) {
                lock[x] = @intCast(y - 1);
                break;
            }
        }
    }
    return lock;
}

fn parseKey(grid: *const common.ImmutableGrid) Key {
    var key: Key = undefined;
    for (0..5) |x| {
        for (0..6) |y| {
            if (!grid.isCharAtPosition(@intCast(x), @intCast(5 - y), '#')) {
                key[x] = @intCast(y);
                break;
            }
        }
    }
    return key;
}

fn keyFitsLock(key: Key, lock: Lock) bool {
    for (0..5) |x| {
        if (key[x] + lock[x] > 5) {
            return false;
        }
    }
    return true;
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\#####
        \\.####
        \\.####
        \\.####
        \\.#.#.
        \\.#...
        \\.....
        \\
        \\#####
        \\##.##
        \\.#.##
        \\...##
        \\...#.
        \\...#.
        \\.....
        \\
        \\.....
        \\#....
        \\#....
        \\#...#
        \\#.#.#
        \\#.###
        \\#####
        \\
        \\.....
        \\.....
        \\#.#..
        \\###..
        \\###.#
        \\###.#
        \\#####
        \\
        \\.....
        \\.....
        \\.....
        \\#....
        \\#.#..
        \\#.#.#
        \\#####
    );
    try std.testing.expectEqual(3, result.p1.i);
}
