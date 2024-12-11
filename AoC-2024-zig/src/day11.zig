const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .Func = .{
    .solve = &solve,
    .benchmarkIterations = 100,
} };

const CacheEntry = struct { num: u64, steps: u64 };
const Cache = std.AutoHashMap(CacheEntry, u64);

fn solve() !aoc.Answers {
    const inp = [_]u64{ 3028, 78, 973951, 5146801, 5, 0, 23533, 857 };

    return .{
        .p1 = .{ .i = try stonesAfterSteps(&inp, 25) },
        .p2 = .{ .i = try stonesAfterSteps(&inp, 75) },
    };
}

fn stonesAfterStepsSingle(stone: u64, steps: u64, cache: *Cache) !u64 {
    if (steps == 0) return 1;
    const key: CacheEntry = .{ .num = stone, .steps = steps };
    if (cache.get(key)) |v| return v;

    var result: u64 = 0;

    if (stone == 0) {
        result = try stonesAfterStepsSingle(1, steps - 1, cache);
    } else if (hasEvenNrOfDigits(stone)) |digits| {
        const left = try numLeft(stone, digits >> 1);
        const right = try numRight(stone, digits >> 1);
        result = try stonesAfterStepsSingle(left, steps - 1, cache) + try stonesAfterStepsSingle(right, steps - 1, cache);
    } else {
        result = try stonesAfterStepsSingle(stone * 2024, steps - 1, cache);
    }

    try cache.put(key, result);
    return result;
}

fn stonesAfterSteps(initial: []const u64, steps: u64) !u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    var cache = Cache.init(allocator);
    defer cache.deinit();

    var result: u64 = 0;
    for (initial) |n| {
        result += try stonesAfterStepsSingle(n, steps, &cache);
    }
    return result;
}

fn hasEvenNrOfDigits(num: u64) ?u8 {
    const digits = std.math.log10_int(num) + 1;
    return if (@mod(digits, 2) == 0) digits else null;
}

inline fn numLeft(num: u64, digits: u8) !u64 {
    return @divTrunc(num, try std.math.powi(u64, 10, digits));
}

inline fn numRight(num: u64, digits: u8) !u64 {
    return @mod(num, try std.math.powi(u64, 10, digits));
}

test "example" {
    const stones = [_]u64{ 125, 17 };
    try std.testing.expectEqual(22, stonesAfterSteps(&stones, 6));
    try std.testing.expectEqual(55312, stonesAfterSteps(&stones, 25));
}

test "hasEvenNrOfDigits" {
    try std.testing.expectEqual(null, hasEvenNrOfDigits(9));
    try std.testing.expectEqual(2, hasEvenNrOfDigits(99));
    try std.testing.expectEqual(null, hasEvenNrOfDigits(999));
}

test "splitting" {
    try std.testing.expectEqual(1, try numLeft(15, 1));
    try std.testing.expectEqual(5, try numRight(15, 1));
    try std.testing.expectEqual(123, try numLeft(123456, 3));
    try std.testing.expectEqual(456, try numRight(123456, 3));
}
