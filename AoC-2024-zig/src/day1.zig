const std = @import("std");
const aoc = @import("aoc.zig");

pub const solution = aoc.Solution{ .Func = &solve };

fn solve() !aoc.Answer {
    var result: u64 = 0;
    for (1..10) |i| {
        result += i;
    }
    return .{ .str = "hi" };
}
