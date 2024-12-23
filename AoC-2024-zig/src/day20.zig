const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day20.txt",
    .solve = &solve,
    .benchmarkIterations = 10,
} };

const Seen = [142][142]bool;
const DistanceMap = std.AutoArrayHashMap(common.Coord, usize);

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: usize = 0;
    var p2: usize = 0;

    const grid = try common.MutableGrid.initCopy(data, allocator);
    defer grid.deinit();

    var seen = std.mem.zeroes(Seen);
    var results = DistanceMap.init(allocator);
    defer results.deinit();

    const start = grid.find('S').?;
    const baseLength = try fillDistanceToEnd(start, &grid, &seen, &results);
    _ = baseLength;

    const cells = results.keys();
    for (0..cells.len) |i| {
        for (i + 1..cells.len) |j| {
            const diff = cells[i].diff(cells[j]);
            const distance = @abs(diff.x) + @abs(diff.y);
            if (distance <= 20 and results.get(cells[j]).? - results.get(cells[i]).? - distance >= 100) {
                p2 += 1;
                if (distance == 2) {
                    p1 += 1;
                }
            }
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn fillDistanceToEnd(pos: common.Coord, grid: *const common.MutableGrid, seen: *Seen, results: *DistanceMap) !usize {
    seen[@intCast(pos.x)][@intCast(pos.y)] = true;
    if (grid.isCharAtPosition(pos.x, pos.y, 'E')) {
        try results.put(pos, 0);
        return 0;
    }

    for (common.allDirections) |direction| {
        const nextCoord = pos.add(direction.vector());
        if (grid.isInsideGrid(nextCoord.x, nextCoord.y) and !seen[@intCast(nextCoord.x)][@intCast(nextCoord.y)] and !grid.isCharAtPosition(nextCoord.x, nextCoord.y, '#')) {
            const d = 1 + try fillDistanceToEnd(nextCoord, grid, seen, results);
            try results.put(pos, d);
            return d;
        }
    }

    @panic("should not get here");
}

test "p2 third time's the charm" {
    const grid = try common.MutableGrid.initCopy(
        \\###############
        \\#...#...#.....#
        \\#.#.#.#.#.###.#
        \\#S#...#.#.#...#
        \\#######.#.#.###
        \\#######.#.#...#
        \\#######.#.###.#
        \\###..E#...#...#
        \\###.#######.###
        \\#...###...#...#
        \\#.#####.#.###.#
        \\#.#...#.#.#...#
        \\#.#.#.#.#.#.###
        \\#...#...#...###
        \\###############
    , std.testing.allocator);
    defer grid.deinit();

    var seen = std.mem.zeroes(Seen);
    var results = DistanceMap.init(std.testing.allocator);
    defer results.deinit();

    const start = grid.find('S').?;
    const baseDistance = try fillDistanceToEnd(start, &grid, &seen, &results);
    try std.testing.expectEqual(84, baseDistance);

    var p1: usize = 0;
    var p2: usize = 0;

    const cells = results.keys();
    for (0..cells.len) |i| {
        for (i + 1..cells.len) |j| {
            const diff = cells[i].diff(cells[j]);
            const distance = @abs(diff.x) + @abs(diff.y);
            if (distance <= 20 and results.get(cells[j]).? - results.get(cells[i]).? - distance >= 50) {
                p2 += 1;
                if (distance == 2) {
                    p1 += 1;
                }
            }
        }
    }
    try std.testing.expectEqual(1, p1);
    try std.testing.expectEqual(285, p2);
}
