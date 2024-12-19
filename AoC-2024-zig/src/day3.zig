const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day3.txt",
    .solve = &solve,
} };

fn ParseResult(valueType: type) type {
    return union(enum) { Success: valueType, Fail: u8 };
}

const DoOrDont = enum { Do, Dont };

fn solve(_: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    var doing = true;
    var i: u32 = 0;
    while (i < data.len) {
        const c = data[i];
        if (c == 'm') {
            switch (parseVerbatim(data[i..], "mul(")) {
                .Success => |_| {
                    i += @intCast("mul(".len);
                    switch (parseNum(data[i..])) {
                        .Success => |num1| {
                            i += num1.size;
                            if (data[i] == ',') {
                                i += 1;
                                switch (parseNum(data[i..])) {
                                    .Success => |num2| {
                                        i += num2.size;
                                        if (data[i] == ')') {
                                            p1 += num1.value * num2.value;
                                            if (doing) {
                                                p2 += num1.value * num2.value;
                                            }
                                        }
                                    },
                                    .Fail => |size| {
                                        i += size;
                                    },
                                }
                            }
                        },
                        .Fail => |size| {
                            i += size;
                        },
                    }
                },
                .Fail => |size| {
                    i += size;
                },
            }
        } else if (c == 'd') {
            switch (parseDoDont(data[i..])) {
                .Success => |result| {
                    i += result.size;
                    if (result.value == DoOrDont.Do) {
                        doing = true;
                    } else {
                        doing = false;
                    }
                },
                .Fail => |size| {
                    i += size;
                },
            }
        } else {
            i += 1;
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn parseVerbatim(data: []const u8, needle: []const u8) ParseResult(u8) {
    for (0..needle.len) |i| {
        if (data[i] != needle[i]) {
            return .{ .Fail = @intCast(i) };
        }
    }
    return .{ .Success = @intCast(needle.len) };
}
fn parseMul(data: []const u8) ParseResult(u8) {
    const needle = "mul(";
    for (0..needle.len) |i| {
        if (data[i] != needle[i]) {
            return .{ .Fail = @intCast(i) };
        }
    }
    return .{ .Success = 0 };
}
fn parseNum(data: []const u8) ParseResult(struct { value: u32, size: u8 }) {
    var i: u8 = 0;
    var result: u32 = 0;
    while (data[i] >= '0' and data[i] <= '9') {
        result = 10 * result + (data[i] - '0');
        i += 1;
    }

    if (i > 0) {
        return .{ .Success = .{ .value = result, .size = i } };
    } else {
        return .{ .Fail = 0 };
    }
}

fn parseDoDont(data: []const u8) ParseResult(struct { value: DoOrDont, size: u8 }) {
    switch (parseVerbatim(data, "do()")) {
        .Success => |_| {
            return .{ .Success = .{ .value = DoOrDont.Do, .size = "do()".len } };
        },
        .Fail => |_| {
            switch (parseVerbatim(data, "don't()")) {
                .Success => |_| {
                    return .{ .Success = .{ .value = DoOrDont.Dont, .size = "don't()".len } };
                },
                .Fail => |_| {
                    return .{ .Fail = 1 };
                },
            }
        },
    }
}

test "example p1" {
    try std.testing.expectEqual(161, (try solve(
        std.testing.allocator,
        "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
    )).p1.i);
}

test "example p2" {
    try std.testing.expectEqual(48, (try solve(
        std.testing.allocator,
        "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
    )).p2.i);
}
