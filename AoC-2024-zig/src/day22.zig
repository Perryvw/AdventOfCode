const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day22.txt",
    .solve = &solve,
    .benchmarkIterations = 1,
} };

const MemoMap = [27]std.StringHashMap(u64);

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    p2 = 0;

    var nums = std.ArrayList(u64).init(allocator);
    defer nums.deinit();

    var cache = std.ArrayList(std.AutoHashMap(i64, i8)).init(allocator);
    defer {
        for (cache.items) |*i| {
            i.deinit();
        }
        cache.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        try nums.append(common.parseInt(u64, line));
    }

    // p1
    for (nums.items) |n| {
        try cache.append(std.AutoHashMap(i64, i8).init(allocator));
        var diffs: [4]i8 = undefined;

        var secret = n;
        for (0..2000) |i| {
            const previous = secret;
            secret = next(secret);

            diffs[0] = diffs[1];
            diffs[1] = diffs[2];
            diffs[2] = diffs[3];
            diffs[3] = price(secret) - price(previous);
            if (i > 2) {
                const h = hash(diffs[0], diffs[1], diffs[2], diffs[3]);
                if (!cache.items[cache.items.len - 1].contains(h)) {
                    try cache.items[cache.items.len - 1].putNoClobber(h, price(secret));
                }
            }
        }
        p1 += secret;
    }

    // p2
    for (0..11) |a| {
        for (0..11) |b| {
            for (0..11) |c| {
                for (0..6) |d| {
                    const seq = [4]i8{ @as(i8, @intCast(a)) - 5, @as(i8, @intCast(b)) - 5, @as(i8, @intCast(c)) - 5, @intCast(d) };
                    var total: u64 = 0;
                    for (cache.items) |buyer| {
                        if (buyer.get(hash(seq[0], seq[1], seq[2], seq[3]))) |p| {
                            total += @intCast(p);
                        }
                    }
                    if (total > p2) {
                        p2 = total;
                    }
                }
            }
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn hash(a: i8, b: i8, c: i8, d: i8) i64 {
    return (@as(i64, @intCast(a + 20)) << 24) + (@as(i64, @intCast(b + 20)) << 16) + (@as(i64, @intCast(c + 20)) << 8) + @as(i64, @intCast(d));
}

fn next(secret: u64) u64 {
    var val = secret;
    val = prune(mix(val * 64, val));
    val = prune(mix(@divTrunc(val, 32), val));
    val = prune(mix(val * 2048, val));
    return val;
}

fn mix(secret: u64, v: u64) u64 {
    return secret ^ v;
}

fn prune(secret: u64) u64 {
    return secret % 16777216;
}

fn price(secret: u64) i8 {
    return @intCast(secret % 10);
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\1
        \\10
        \\100
        \\2024
    );
    try std.testing.expectEqual(37327623, result.p1.i);
}

test "example p2" {
    const result = try solve(std.testing.allocator,
        \\1
        \\2
        \\3
        \\2024
    );
    try std.testing.expectEqual(23, result.p2.i);
}

test "next" {
    try std.testing.expectEqual(15887950, next(123));
    try std.testing.expectEqual(16495136, next(15887950));
    try std.testing.expectEqual(527345, next(16495136));
    try std.testing.expectEqual(704524, next(527345));
}
