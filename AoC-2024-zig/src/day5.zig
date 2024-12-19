const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day5.txt",
    .solve = &solve,
} };

const DependencyMap = std.AutoHashMap(u8, std.ArrayList(u8));

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: i32 = 0;
    var p2: i32 = 0;

    const split = std.mem.indexOf(u8, data, "\n\n").?;

    var dependencyMap = DependencyMap.init(allocator);
    defer {
        var valueIter = dependencyMap.valueIterator();
        while (valueIter.next()) |v| {
            v.deinit();
        }
        dependencyMap.deinit();
    }

    var iter = std.mem.tokenizeScalar(u8, data[0..split], '\n');
    while (iter.next()) |line| {
        const bar = std.mem.indexOf(u8, line, "|").?;
        const page = common.parseInt(u8, line[0..bar]);
        const mustBeBefore = common.parseInt(u8, line[(bar + 1)..]);

        if (dependencyMap.getPtr(page)) |precedes| {
            try precedes.append(mustBeBefore);
        } else {
            var precedes = std.ArrayList(u8).init(allocator);
            try precedes.append(mustBeBefore);
            try dependencyMap.put(page, precedes);
        }
    }

    iter = std.mem.tokenizeScalar(u8, data[(split + 2)..], '\n');
    while (iter.next()) |line| {
        var safe = true;
        var before: [30]u8 = undefined;
        var i: u8 = 0;
        var numIter = std.mem.tokenizeScalar(u8, line, ',');
        while (numIter.next()) |numStr| {
            const num = common.parseInt(u8, numStr);
            before[i] = num;
            i += 1;
            if (safe) {
                if (dependencyMap.get(num)) |mustBeBefore| {
                    for (mustBeBefore.items) |n| {
                        if (std.mem.indexOfScalar(u8, before[0..(i - 1)], n)) |_| {
                            safe = false;
                        }
                    }
                }
            }
        }
        if (safe) {
            p1 += middlePage(before[0..i]);
        } else {
            std.mem.sort(u8, before[0..i], dependencyMap, sortFunc);
            p2 += middlePage(before[0..i]);
        }
    }

    return .{
        .p1 = .{ .i = @intCast(p1) },
        .p2 = .{ .i = @intCast(p2) },
    };
}

fn sortFunc(dependencyMap: DependencyMap, left: u8, right: u8) bool {
    if (dependencyMap.get(left)) |follwing| {
        for (follwing.items) |i| {
            if (i == right) {
                return true;
            }
        }
    }
    return false;
}

fn middlePage(pages: []const u8) u8 {
    return pages[@divTrunc(pages.len, 2)];
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    );
    try std.testing.expectEqual(143, result.p1.i);
    try std.testing.expectEqual(123, result.p2.i);
}
