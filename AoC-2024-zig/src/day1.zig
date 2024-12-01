const std = @import("std");
const aoc = @import("aoc.zig");

const common = @import("common.zig");

const NUM_LINES = 1000;
const INT_WIDTH = 5;

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day1.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answers {
    var list1 = std.mem.zeroes([NUM_LINES]i32);
    var list2 = std.mem.zeroes([NUM_LINES]i32);

    var i: u32 = 0;
    var iter = common.LinesIterator{ .string = data };
    while (iter.next()) |line| {
        const left = common.parseInt(i32, line[0..INT_WIDTH]);
        const right = common.parseInt(i32, line[(INT_WIDTH + 3)..(INT_WIDTH * 2 + 3)]);

        list1[i] = left;
        list2[i] = right;

        i += 1;
    }

    std.mem.sort(i32, &list1, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, &list2, {}, comptime std.sort.asc(i32));

    var p1: u64 = 0;
    for (0..i) |n| {
        const diff = @abs(list1[n] - list2[n]);
        p1 += diff;
    }

    var map = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    for (0..i) |n| {
        const v = list2[n];
        const oldValue = try map.getOrPutValue(v, 0);
        try map.put(v, oldValue.value_ptr.* + 1);
    }

    var p2: u64 = 0;
    for (0..i) |n| {
        const left = list1[n];
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
