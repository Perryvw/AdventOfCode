const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day10.txt",
    .solve = &solve,
} };

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    const grid = common.ImmutableGrid.init(data);

    var seen = std.AutoHashMap(u64, bool).init(allocator);
    defer seen.deinit();

    for (0..grid.height) |y| {
        for (0..grid.width) |x| {
            if (grid.isCharAtPosition(@intCast(x), @intCast(y), '0')) {
                // Trailhead
                const r = try numHikes(&grid, .{ .x = @intCast(x), .y = @intCast(y) }, &seen);
                p1 += r.unique;
                p2 += r.all;
                seen.clearRetainingCapacity();
            }
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = @intCast(p2) },
    };
}

const HikesResult = struct { unique: u32, all: u32 };

fn numHikes(grid: *const common.ImmutableGrid, pos: common.Coord, seen: *std.AutoHashMap(u64, bool)) !HikesResult {
    if (grid.isCharAtPosition(pos.x, pos.y, '9')) {
        const h = hash(pos);
        var unique: u32 = 0;
        if (!seen.contains(h)) {
            try seen.put(h, true);
            unique = 1;
        }
        return .{ .unique = unique, .all = 1 };
    }

    var result: HikesResult = .{ .all = 0, .unique = 0 };

    const nextChar = grid.charAtPos(pos.x, pos.y).? + 1;
    for (common.allDirections) |direction| {
        const p = pos.add(direction.vector());
        if (grid.isCharAtPosition(p.x, p.y, nextChar)) {
            const r = try numHikes(grid, p, seen);
            result.all += r.all;
            result.unique += r.unique;
        }
    }

    return result;
}

fn hash(pos: common.Coord) u64 {
    return @as(u64, @intCast(pos.x)) * 1000 + @as(u64, @intCast(pos.y));
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\0123
        \\1234
        \\8765
        \\9876
    );
    try std.testing.expectEqual(1, result.p1.i);
}
test "example 2" {
    const result = try solve(std.testing.allocator,
        \\...0...
        \\...1...
        \\...2...
        \\6543456
        \\7.....7
        \\8.....8
        \\9.....9
    );
    try std.testing.expectEqual(2, result.p1.i);
}
test "example 4" {
    const result = try solve(std.testing.allocator,
        \\..90..9
        \\...1.98
        \\...2..7
        \\6543456
        \\765.987
        \\876....
        \\987....
    );
    try std.testing.expectEqual(4, result.p1.i);
}
test "example 5" {
    const result = try solve(std.testing.allocator,
        \\10..9..
        \\2...8..
        \\3...7..
        \\4567654
        \\...8..3
        \\...9..2
        \\.....01
    );
    try std.testing.expectEqual(3, result.p1.i);
}
test "larger example" {
    const result = try solve(std.testing.allocator,
        \\89010123
        \\78121874
        \\87430965
        \\96549874
        \\45678903
        \\32019012
        \\01329801
        \\10456732
    );
    try std.testing.expectEqual(36, result.p1.i);
    try std.testing.expectEqual(81, result.p2.i);
}
