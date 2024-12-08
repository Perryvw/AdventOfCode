const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day8.txt",
    .solve = &solve,
} };

const Coord = struct { x: i32, y: i32 };

fn solve(data: []const u8) !aoc.Answers {
    var p1: u32 = 0;
    var p2: u32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    const width = std.mem.indexOf(u8, data, "\n").?;
    const height = @divTrunc(data.len, width);

    const grid: common.Grid = .{ .data = data, .width = width, .height = height };

    var antennas = std.AutoHashMap(u8, std.ArrayList(Coord)).init(allocator);
    defer {
        var iter = antennas.valueIterator();
        while (iter.next()) |l| l.deinit();
        antennas.deinit();
    }

    for (0..height) |y| {
        for (0..width) |x| {
            const c = grid.charAtPos(@intCast(x), @intCast(y)).?;
            if (c != '.') {
                const antenna: Coord = .{
                    .x = @intCast(x),
                    .y = @intCast(y),
                };
                if (antennas.getPtr(c)) |antennasOfType| {
                    try antennasOfType.append(antenna);
                } else {
                    var list = std.ArrayList(Coord).init(allocator);
                    try list.append(antenna);
                    try antennas.put(c, list);
                }
            }
        }
    }

    var antiNodes = std.AutoHashMap(i64, bool).init(allocator);
    defer antiNodes.deinit();
    var antiNodes2 = std.AutoHashMap(i64, bool).init(allocator);
    defer antiNodes2.deinit();

    var iter = antennas.valueIterator();
    while (iter.next()) |antennaList| {
        for (0..antennaList.items.len) |i| {
            for ((i + 1)..antennaList.items.len) |j| {
                const antenna1 = antennaList.items[i];
                const antenna2 = antennaList.items[j];

                const dx = antenna2.x - antenna1.x;
                const dy = antenna2.y - antenna1.y;

                var an1x = antenna1.x - dx;
                var an1y = antenna1.y - dy;
                var an2x = antenna2.x + dx;
                var an2y = antenna2.y + dy;

                if (grid.isInsideGrid(an1x, an1y)) {
                    try antiNodes.put(hash(an1x, an1y), true);
                }
                if (grid.isInsideGrid(an2x, an2y)) {
                    try antiNodes.put(hash(an2x, an2y), true);
                }

                try antiNodes2.put(hash(antenna1.x, antenna1.y), true);
                try antiNodes2.put(hash(antenna2.x, antenna2.y), true);

                while (grid.isInsideGrid(an1x, an1y)) {
                    try antiNodes2.put(hash(an1x, an1y), true);
                    an1x -= dx;
                    an1y -= dy;
                }

                while (grid.isInsideGrid(an2x, an2y)) {
                    try antiNodes2.put(hash(an2x, an2y), true);
                    an2x += dx;
                    an2y += dy;
                }
            }
        }
    }

    p1 = antiNodes.count();
    p2 = antiNodes2.count();

    return .{
        .p1 = .{ .i = @intCast(p1) },
        .p2 = .{ .i = @intCast(p2) },
    };
}

fn hash(a: i32, b: i32) i64 {
    return @as(i64, a) * 10000 + b;
}

test "example" {
    const result = try solve(
        \\............
        \\........0...
        \\.....0......
        \\.......0....
        \\....0.......
        \\......A.....
        \\............
        \\............
        \\........A...
        \\.........A..
        \\............
        \\............
    );
    try std.testing.expectEqual(14, result.p1.i);
    try std.testing.expectEqual(34, result.p2.i);
}
