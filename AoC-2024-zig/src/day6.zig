const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day6.txt",
    .solve = &solve,
    .benchmarkIterations = 5,
} };

const Direction = enum { Up, Right, Down, Left };

const Grid = struct {
    data: []u8,
    width: usize,
    height: usize,

    fn isInsideGrid(self: *const Grid, x: i32, y: i32) bool {
        return x >= 0 and x < self.width and y >= 0 and y < self.height;
    }

    fn isCharAtPosition(self: *const Grid, x: i32, y: i32, c: u8) bool {
        if (!self.isInsideGrid(x, y)) return false;
        return self.data[self.pos(x, y)] == c;
    }

    fn charAtPos(self: *const Grid, x: i32, y: i32) ?u8 {
        if (!self.isInsideGrid(x, y)) return null;

        return self.data[self.pos(x, y)];
    }

    fn pos(self: *const Grid, x: i32, y: i32) usize {
        std.debug.assert(x >= 0);
        std.debug.assert(x < self.width);
        std.debug.assert(y >= 0);
        std.debug.assert(y < self.height);
        // +1 to account for newlines
        return @intCast(@as(i32, @intCast(self.width + 1)) * y + x);
    }
};

fn solve(data: []const u8) !aoc.Answers {
    var p1: i32 = 0;
    var p2: i32 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    const width = std.mem.indexOf(u8, data, "\n").?;
    const height = @divTrunc(data.len, width);

    const gridData = try allocator.alloc(u8, data.len);
    defer allocator.free(gridData);
    @memcpy(gridData, data);

    const grid: Grid = .{ .data = gridData, .width = width, .height = height };

    const guardPos = std.mem.indexOf(u8, data, "^").?;

    const startDir = Direction.Up;
    const startX: i32 = @intCast(@rem(guardPos, width + 1));
    const startY: i32 = @intCast(@divTrunc(guardPos, width + 1));

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

    // Subtract one for when we are outside the grid
    p1 = @intCast(seen.count() - 1);

    p2 = @intCast(p2Seen.count());

    return .{
        .p1 = .{ .i = @intCast(p1) },
        .p2 = .{ .i = @intCast(p2) },
    };
}

fn stepsUntilOutside(
    grid: *const Grid,
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
