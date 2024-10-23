const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day2.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answer {
    var result: u64 = 0;
    var iter = common.LinesIterator{ .string = data };
    while (iter.next()) |_| {
        //std.log.info("{s}", .{line});
        result += 1;
    }
    return .{ .i = result };
}
