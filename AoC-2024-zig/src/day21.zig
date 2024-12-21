const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day21.txt",
    .solve = &solve,
    .benchmarkIterations = 10,
} };

const MemoMap = [27]std.StringHashMap(u64);

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    var cache: MemoMap = undefined;
    for (0..cache.len) |i| {
        cache[i] = std.StringHashMap(u64).init(allocator);
    }
    defer {
        for (0..cache.len) |i| {
            cache[i].deinit();
        }
    }

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        p1 += try complexity(arena.allocator(), line, 2, &cache);
        p2 += try complexity(arena.allocator(), line, 25, &cache);
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn complexity(allocator: std.mem.Allocator, code: []const u8, depth: u8, cache: *MemoMap) !u64 {
    const numericPart = common.parseInt(u32, code[0 .. code.len - 1]);
    const cost = try costForSequence(allocator, code, depth + 1, keyPosLarge, cache);
    return numericPart * cost;
}

fn sequencesForDiff(allocator: std.mem.Allocator, from: common.Coord, to: common.Coord, head: std.ArrayList(u8), illegalY: i32) !std.ArrayList(std.ArrayList(u8)) {
    var result = std.ArrayList(std.ArrayList(u8)).init(allocator);
    if (from.x == to.x and from.y == to.y) {
        var h = try head.clone();
        try h.append('A');
        try result.append(h);
        return result;
    }

    if (from.x > to.x and (from.x != 1 or from.y != illegalY)) {
        var next = try head.clone();
        try next.append('<');
        try result.appendSlice((try sequencesForDiff(allocator, .{ .x = from.x - 1, .y = from.y }, to, next, illegalY)).items);
    } else if (from.x < to.x) {
        var next = try head.clone();
        try next.append('>');
        try result.appendSlice((try sequencesForDiff(allocator, .{ .x = from.x + 1, .y = from.y }, to, next, illegalY)).items);
    }
    if (from.y > to.y) {
        var next = try head.clone();
        try next.append('^');
        try result.appendSlice((try sequencesForDiff(allocator, .{ .x = from.x, .y = from.y - 1 }, to, next, illegalY)).items);
    } else if (from.y < to.y and (from.x != 0 or from.y != illegalY - 1)) {
        var next = try head.clone();
        try next.append('v');
        try result.appendSlice((try sequencesForDiff(allocator, .{ .x = from.x, .y = from.y + 1 }, to, next, illegalY)).items);
    }

    return result;
}

fn costForSequence(allocator: std.mem.Allocator, seq: []const u8, depth: u8, keyPos: *const fn (u8) common.Coord, cache: *MemoMap) !u64 {
    if (cache[depth].get(seq)) |c| {
        return c;
    }

    if (depth == 0) {
        return seq.len;
    }

    var pos: u8 = 'A';
    var totalCost: u64 = 0;
    for (seq) |c| {
        const seqs = try sequencesForDiff(allocator, keyPos(pos), keyPos(c), std.ArrayList(u8).init(allocator), keyPos('A').y);

        var minCost: usize = std.math.maxInt(usize);
        for (seqs.items) |child_seq| {
            const cost = try costForSequence(allocator, child_seq.items, depth - 1, keyPosSmall, cache);
            if (cost < minCost) {
                minCost = cost;
            }
        }
        totalCost += minCost;

        pos = c;
    }
    try cache[depth].put(seq, totalCost);
    return totalCost;
}

fn keyPosLarge(k: u8) common.Coord {
    return switch (k) {
        '7' => .{ .x = 0, .y = 0 },
        '8' => .{ .x = 1, .y = 0 },
        '9' => .{ .x = 2, .y = 0 },
        '4' => .{ .x = 0, .y = 1 },
        '5' => .{ .x = 1, .y = 1 },
        '6' => .{ .x = 2, .y = 1 },
        '1' => .{ .x = 0, .y = 2 },
        '2' => .{ .x = 1, .y = 2 },
        '3' => .{ .x = 2, .y = 2 },
        '0' => .{ .x = 1, .y = 3 },
        'A' => .{ .x = 2, .y = 3 },
        else => @panic("unknown key!"),
    };
}

fn keyPosSmall(k: u8) common.Coord {
    return switch (k) {
        '^' => .{ .x = 1, .y = 0 },
        'A' => .{ .x = 2, .y = 0 },
        '<' => .{ .x = 0, .y = 1 },
        'v' => .{ .x = 1, .y = 1 },
        '>' => .{ .x = 2, .y = 1 },
        else => @panic("unknown key!"),
    };
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\029A
        \\980A
        \\179A
        \\456A
        \\379A
    );
    try std.testing.expectEqual(126384, result.p1.i);
    try std.testing.expectEqual(154115708116294, result.p2.i);
}
