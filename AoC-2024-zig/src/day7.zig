const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day7.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    var nums: [20]u32 = undefined;

    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        const split = std.mem.indexOfScalar(u8, line, ':').?;
        const value = common.parseInt(u64, line[0..split]);

        var count: usize = 0;
        var numIter = std.mem.tokenizeScalar(u8, line[(split + 1)..], ' ');
        while (numIter.next()) |numStr| {
            nums[count] = common.parseInt(u32, numStr);
            count += 1;
        }

        if (try canReachValue(nums[0..count], value, false)) {
            p1 += value;
        }
        if (try canReachValue(nums[0..count], value, true)) {
            p2 += value;
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = @intCast(p2) },
    };
}

fn canReachValue(ns: []const u32, target: u64, concat: bool) error{ Overflow, Underflow }!bool {
    if (ns.len == 0) return target == 0;
    if (ns.len == 1) return target == ns[0];

    return try canReachWithMultiplication(ns, target, concat) or try canReachWithAddition(ns, target, concat) or (concat and try canReachWithConcatenation(ns, target));
}

fn canReachWithMultiplication(ns: []const u32, target: u64, concat: bool) !bool {
    const last = ns[ns.len - 1];
    if (@mod(target, last) != 0) return false;
    return try canReachValue(ns[0 .. ns.len - 1], @divExact(target, last), concat);
}

fn canReachWithAddition(ns: []const u32, target: u64, concat: bool) !bool {
    const last = ns[ns.len - 1];
    return try canReachValue(ns[0 .. ns.len - 1], target - last, concat);
}

fn canReachWithConcatenation(ns: []const u32, target: u64) !bool {
    const last = ns[ns.len - 1];
    const mag = try magnitude(last);
    if (@mod(target - last, mag) != 0) return false;
    return try canReachValue(ns[0 .. ns.len - 1], @divExact(target - last, try magnitude(last)), true);
}

inline fn magnitude(v: u32) !u32 {
    return try std.math.powi(u32, 10, std.math.log10_int(v) + 1);
}

test "example" {
    const result = try solve(
        \\190: 10 19
        \\3267: 81 40 27
        \\83: 17 5
        \\156: 15 6
        \\7290: 6 8 6 15
        \\161011: 16 10 13
        \\192: 17 8 14
        \\21037: 9 7 18 13
        \\292: 11 6 16 20
    );
    try std.testing.expectEqual(3749, result.p1.i);
    try std.testing.expectEqual(11387, result.p2.i);
}

test "magnitude" {
    try std.testing.expectEqual(try magnitude(99), 100);
    try std.testing.expectEqual(try magnitude(100), 1000);
    try std.testing.expectEqual(try magnitude(999), 1000);
    try std.testing.expectEqual(try magnitude(1), 10);
}
