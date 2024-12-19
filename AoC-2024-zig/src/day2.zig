const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day2.txt",
    .solve = &solve,
} };

const Direction = enum { Increasing, Decreasing };

fn solve(_: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: i32 = 0;
    var p2: i32 = 0;

    var reports = std.mem.tokenizeScalar(u8, data, '\n');
    while (reports.next()) |report| {
        if (isValidSequence(report, 0)) {
            p1 += 1;
            p2 += 1;
        } else if (isValidSequence(report, 1)) {
            p2 += 1;
        }
    }

    return .{
        .p1 = .{ .i = @intCast(p1) },
        .p2 = .{ .i = @intCast(p2) },
    };
}

fn isValidSequence(report: []const u8, allowedErrors: u8) bool {
    var levels = std.mem.tokenizeScalar(u8, report, ' ');
    const first = common.parseInt(i32, levels.next().?);
    const second = common.parseInt(i32, levels.next().?);

    const validIncreasing = _isValidSequence(first, second, report[levels.index..], Direction.Increasing, allowedErrors);
    const validDecreasing = _isValidSequence(first, second, report[levels.index..], Direction.Decreasing, allowedErrors);
    return validIncreasing or validDecreasing;
}

fn _isValidSequence(first: i32, second: i32, report: []const u8, direction: Direction, allowedErrors: u8) bool {
    var previous0 = first;
    var previous = second;

    var levels = std.mem.tokenizeScalar(u8, report, ' ');

    if (!isValidNext(first, second, direction)) {
        if (allowedErrors == 0) return false;

        if (levels.next()) |levelStr| {
            const level = common.parseInt(i32, levelStr);
            // Either first is wrong
            const case1 = _isValidSequence(second, level, report[levels.index..], direction, allowedErrors - 1);
            // Or second is wrong
            const case2 = _isValidSequence(first, level, report[levels.index..], direction, allowedErrors - 1);
            return case1 or case2;
        } else {
            // no more nrs but we are still allowed errors, so this is valid
            return true;
        }
    }

    while (levels.next()) |levelStr| {
        const level = common.parseInt(i32, levelStr);

        if (isValidNext(previous, level, direction)) {
            previous0 = previous;
            previous = level;
        } else if (allowedErrors == 0) {
            return false;
        } else {
            // Either the current (level) is wrong, or the previous is wrong
            // Rerun the check without level
            const case1 = _isValidSequence(previous0, previous, report[levels.index..], direction, allowedErrors - 1);
            // Rerun the check without previous but with level
            const case2 = _isValidSequence(previous0, level, report[levels.index..], direction, allowedErrors - 1);
            return case1 or case2;
        }
    }

    return true;
}

fn isValidNext(previous: i32, next: i32, direction: Direction) bool {
    const directionValid = (direction == Direction.Increasing and (previous < next)) or (direction == Direction.Decreasing and (previous > next));
    const differenceValid = isValidDifference(previous, next);
    return directionValid and differenceValid;
}

fn isValidDifference(a: i32, b: i32) bool {
    const diff = @abs(a - b);
    return (diff >= 1) and (diff <= 3);
}

test "example input" {
    const r = try solve(std.testing.allocator,
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    );
    try std.testing.expectEqual(2, r.p1.i);
    try std.testing.expectEqual(4, r.p2.i);
}

test "p2: second character wrong" {
    try std.testing.expectEqual(1, (try solve(std.testing.allocator, "1 3 2 4 5")).p2.i);
}

test "p2: second character wrong direction" {
    try std.testing.expectEqual(1, (try solve(std.testing.allocator, "10 3 11 12 13")).p2.i);
}

test "p2: second character right direction but wrong" {
    try std.testing.expectEqual(1, (try solve(std.testing.allocator, "10 3 11 12 13")).p2.i);
}

test "p2: first character wrong" {
    try std.testing.expectEqual(1, (try solve(std.testing.allocator, "10 1 2 4 5")).p2.i);
}

test "p2" {
    const r = try solve(std.testing.allocator,
        \\48 46 47 49 51 54 56
        \\1 1 2 3 4 5
        \\1 2 3 4 5 5
        \\5 1 2 3 4 5
        \\1 4 3 2 1
        \\1 6 7 8 9
        \\1 2 3 4 3
        \\9 8 7 6 7
        \\7 10 8 10 11
        \\29 28 27 25 26 25 22 20
    );
    try std.testing.expectEqual(10, r.p2.i);
}
