const std = @import("std");
const aoc = @import("aoc.zig");

const common = @import("common.zig");

const INPUT_BUFFER = 1000;

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day1.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answers {
    var leftList: [INPUT_BUFFER]i32 = undefined;
    var rightList: [INPUT_BUFFER]i32 = undefined;

    var i: u32 = 0;
    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        const intWidth = @divExact(line.len - 3, 2);
        const left = common.parseInt(i32, line[0..intWidth]);
        const right = common.parseInt(i32, line[(intWidth + 3)..(intWidth * 2 + 3)]);

        leftList[i] = left;
        rightList[i] = right;

        i += 1;
    }

    std.mem.sort(i32, leftList[0..i], {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, rightList[0..i], {}, comptime std.sort.asc(i32));

    var p1: u64 = 0;
    for (0..i) |n| {
        const diff = @abs(leftList[n] - rightList[n]);
        p1 += diff;
    }

    var map = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    for (0..i) |n| {
        const v = rightList[n];
        const oldValue = try map.getOrPutValue(v, 0);
        try map.put(v, oldValue.value_ptr.* + 1);
    }

    var p2: u64 = 0;
    for (0..i) |n| {
        const left = leftList[n];
        const count = map.get(left);
        if (count) |c| {
            p2 += @intCast(left * c);
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

test "example input" {
    const r = try solve(
        \\3   4
        \\4   3
        \\2   5
        \\1   3
        \\3   9
        \\3   3
    );
    try std.testing.expectEqual(11, r.p1.i);
    try std.testing.expectEqual(31, r.p2.i);
}
