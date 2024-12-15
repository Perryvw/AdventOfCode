const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day6.txt",
    .solve = &solve,
    .benchmarkIterations = 5,
} };

const Direction = enum { Up, Right, Down, Left };

fn solve(data: []const u8) !aoc.Answers {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    const grid = common.ImmutableGrid.init(data);

    const guardPos = std.mem.indexOf(u8, data, "^").?;

    const startDir = Direction.Up;
    const startX: i32 = @intCast(@rem(guardPos, grid.width + 1));
    const startY: i32 = @intCast(@divTrunc(guardPos, grid.width + 1));

    var direction = startDir;
    var guardX = startX;
    var guardY = startY;

    var seen = std.AutoHashMap(i64, bool).init(allocator);
    defer seen.deinit();
    var seenDirection = std.AutoHashMap(i64, bool).init(allocator);
    defer seenDirection.deinit();

    var p2Seen = std.AutoHashMap(i64, bool).init(allocator);
    defer p2Seen.deinit();

    var hm1 = std.AutoHashMap(i64, bool).init(allocator);
    defer hm1.deinit();

    var hm2 = std.AutoHashMap(i64, bool).init(allocator);
    defer hm2.deinit();

    while (grid.isInsideGrid(guardX, guardY)) {
        const dx: i32, const dy: i32 = directionVector(direction);

        if (grid.isCharAtPosition(guardX + dx, guardY + dy, '#')) {
            direction = turnRight(direction);
            continue;
        } else {
            hm1.clearRetainingCapacity();
            hm2.clearRetainingCapacity();
            if (try stepsUntilOutside(
                &grid,
                startX,
                startY,
                startDir,
                guardX + dx,
                guardY + dy,
                &hm1,
                &hm2,
            )) |_| {} else {
                try p2Seen.put(hash(guardX + dx, guardY + dy), true);
            }
        }

        try seenDirection.put(hashDirection(guardX, guardY, direction), true);

        guardX += dx;
        guardY += dy;
        try seen.put(hash(guardX, guardY), true);
    }

    return .{
        .p1 = .{
            // Subtract one for when we are outside the grid
            .i = seen.count() - 1,
        },
        .p2 = .{ .i = p2Seen.count() },
    };
}

fn stepsUntilOutside(
    grid: *const common.ImmutableGrid,
    startX: i32,
    startY: i32,
    startDir: Direction,
    obstacleX: i32,
    obstacleY: i32,
    seen: *std.AutoHashMap(i64, bool),
    seenDirection: *std.AutoHashMap(i64, bool),
) !?i32 {
    var guardX = startX;
    var guardY = startY;
    var direction = startDir;

    while (grid.isInsideGrid(guardX, guardY)) {
        const ndh = hashDirection(guardX, guardY, direction);
        if (seenDirection.get(ndh)) |_| {
            return null;
        }
        try seenDirection.put(ndh, true);

        const dx: i32, const dy: i32 = directionVector(direction);

        while (grid.isInsideGrid(guardX, guardY)) {
            if (grid.isCharAtPosition(guardX + dx, guardY + dy, '#') or (guardX + dx == obstacleX and guardY + dy == obstacleY)) {
                direction = turnRight(direction);
                break;
            }

            guardX += dx;
            guardY += dy;

            try seen.put(hash(guardX, guardY), true);
        }
    }

    // Subtract one for when we are outside the grid
    return @intCast(seen.count() - 1);
}

fn hash(x: i32, y: i32) i64 {
    return @as(i64, x) * 1000 + @as(i64, y);
}

fn hashDirection(x: i32, y: i32, direction: Direction) i64 {
    return @as(i64, x) * 10000 + @as(i64, y) * 10 + @intFromEnum(direction);
}

fn turnRight(dir: Direction) Direction {
    return switch (dir) {
        .Up => .Right,
        .Right => .Down,
        .Down => .Left,
        .Left => .Up,
    };
}

fn directionVector(dir: Direction) std.meta.Tuple(&[_]type{ i32, i32 }) {
    return switch (dir) {
        .Up => .{ 0, -1 },
        .Down => .{ 0, 1 },
        .Left => .{ -1, 0 },
        .Right => .{ 1, 0 },
    };
}

test "example" {
    const result = try solve(
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    );
    try std.testing.expectEqual(41, result.p1.i);
    try std.testing.expectEqual(6, result.p2.i);
}

test "edge case" {
    const result = try solve(
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\....##.#..
        \\#....#....
        \\.#.#^.....
        \\........#.
        \\#.........
        \\......#...
    );
    try std.testing.expectEqual(5, result.p1.i);
    try std.testing.expectEqual(1, result.p2.i);
}

test "hash with direction" {
    try std.testing.expectEqual(200100, hashDirection(20, 10, .Up));
    try std.testing.expectEqual(1234563, hashDirection(123, 456, .Left));
    try std.testing.expectEqual(250152, hashDirection(25, 15, .Down));
}
