const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day19.txt",
    .solve = &solve,
    .benchmarkIterations = 100,
} };

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    var linesIter = std.mem.tokenizeScalar(u8, data, '\n');
    const firstLine = linesIter.next().?;

    var towels = std.ArrayList([]const u8).init(allocator);
    defer towels.deinit();

    var iter = std.mem.tokenize(u8, firstLine, ", ");
    while (iter.next()) |towel| {
        try towels.append(towel);
    }

    var p2Cache = std.StringHashMap(u64).init(allocator);
    defer p2Cache.deinit();

    while (linesIter.next()) |line| {
        if (designPossible(line, towels.items)) {
            p1 += 1;
        }
        p2 += try numPossibilities(line, towels.items, &p2Cache);
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn designPossible(design: []const u8, towels: []const []const u8) bool {
    if (design.len == 0) return true;

    for (towels) |towel| {
        if (design.len >= towel.len) {
            if (std.mem.eql(u8, design[0..towel.len], towel)) {
                if (designPossible(design[towel.len..], towels)) {
                    return true;
                }
            }
        }
    }
    return false;
}

fn numPossibilities(design: []const u8, towels: []const []const u8, cache: *std.StringHashMap(u64)) !u64 {
    if (design.len == 0) return 1;

    if (cache.get(design)) |num| {
        return num;
    }

    var result: u64 = 0;

    for (towels) |towel| {
        if (design.len >= towel.len) {
            if (std.mem.eql(u8, design[0..towel.len], towel)) {
                result += try numPossibilities(design[towel.len..], towels, cache);
            }
        }
    }

    try cache.put(design, result);

    return result;
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\r, wr, b, g, bwu, rb, gb, br
        \\
        \\brwrr
        \\bggr
        \\gbbr
        \\rrbgbr
        \\ubwu
        \\bwurrg
        \\brgr
        \\bbrgwb
    );
    try std.testing.expectEqual(6, result.p1.i);
    try std.testing.expectEqual(16, result.p2.i);
}
