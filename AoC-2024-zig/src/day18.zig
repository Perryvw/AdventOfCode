const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day18.txt",
    .solve = &solve,
    .benchmarkIterations = 1,
} };

fn solve(data: []const u8) !aoc.Answers {
    const p1: u64 = (try solvep1(data, 70, 70, 1024)).?;
    const p2: u64 = try solvep2(data, 70, 70, 348);

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn solvep1(data: []const u8, width: u32, height: u32, inputLen: u32) !?u64 {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    var buffer = std.mem.zeroes([71 * 71]bool);
    const grid: common.Grid([]bool) = .{
        .data = &buffer,
        .width = width + 1,
        .height = height + 1,
        .allocator = null,
    };

    var i: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        if (i >= inputLen) break;

        const x, const y = parseNums(line);
        grid.put(x, y, true);

        i += 1;
    }

    // BFS
    var current = std.ArrayList(common.Coord).init(allocator);
    defer current.deinit();
    var next = std.ArrayList(common.Coord).init(allocator);
    defer next.deinit();
    var seen = std.AutoHashMap(common.Coord, bool).init(allocator);
    defer seen.deinit();

    try current.append(.{ .x = 0, .y = 0 });
    var result: ?u64 = null;
    var steps: u64 = 0;

    outer: while (current.items.len > 0) {
        for (current.items) |pos| {
            if (pos.x + 1 == width and pos.y == height) {
                result = steps + 1;
                break :outer;
            }
            if (pos.x == width and pos.y + 1 == height) {
                result = steps + 1;
                break :outer;
            }

            if (grid.isInsideGrid(pos.x + 1, pos.y)) {
                const nextPos: common.Coord = .{ .x = pos.x + 1, .y = pos.y };
                if (!seen.contains(nextPos) and grid.data[grid.pos(nextPos.x, nextPos.y)] == false) {
                    try seen.put(nextPos, true);
                    try next.append(nextPos);
                }
            }
            if (grid.isInsideGrid(pos.x - 1, pos.y)) {
                const nextPos: common.Coord = .{ .x = pos.x - 1, .y = pos.y };
                if (!seen.contains(nextPos) and grid.data[grid.pos(nextPos.x, nextPos.y)] == false) {
                    try seen.put(nextPos, true);
                    try next.append(nextPos);
                }
            }
            if (grid.isInsideGrid(pos.x, pos.y + 1)) {
                const nextPos: common.Coord = .{ .x = pos.x, .y = pos.y + 1 };
                if (!seen.contains(nextPos) and grid.data[grid.pos(nextPos.x, nextPos.y)] == false) {
                    try seen.put(nextPos, true);
                    try next.append(nextPos);
                }
            }
            if (grid.isInsideGrid(pos.x, pos.y - 1)) {
                const nextPos: common.Coord = .{ .x = pos.x, .y = pos.y - 1 };
                if (!seen.contains(nextPos) and grid.data[grid.pos(nextPos.x, nextPos.y)] == false) {
                    try seen.put(nextPos, true);
                    try next.append(nextPos);
                }
            }
        }

        steps += 1;

        current.clearRetainingCapacity();
        try current.appendSlice(next.items);
        next.clearRetainingCapacity();
    }

    return result;
}

fn solvep2(data: []const u8, width: u32, height: u32, start: u32) !u64 {
    var i: u32 = 0;
    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    var previous: []const u8 = "";
    while (lines.next()) |line| {
        if (i >= start) {
            if (try solvep1(data, width, height, i) == null) {
                const x, const y = parseNums(previous);
                return @as(u64, @intCast(x)) * 1000 + y;
            }
        }
        previous = line;
        i += 1;
    }
    return 0;
}

fn parseNums(line: []const u8) std.meta.Tuple(&.{ u8, u8 }) {
    var nums = std.mem.tokenizeScalar(u8, line, ',');
    return .{
        common.parseInt(u8, nums.next().?),
        common.parseInt(u8, nums.next().?),
    };
}

test "example p1" {
    const result = try solvep1(
        \\5,4
        \\4,2
        \\4,5
        \\3,0
        \\2,1
        \\6,3
        \\2,4
        \\1,5
        \\0,6
        \\3,3
        \\2,6
        \\5,1
        \\1,2
        \\5,5
        \\2,5
        \\6,5
        \\1,4
        \\0,4
        \\6,4
        \\1,1
        \\6,1
        \\1,0
        \\0,5
        \\1,6
        \\2,0
    , 6, 6, 12);
    try std.testing.expectEqual(22, result);
}

test "example p2" {
    const result = try solvep2(
        \\5,4
        \\4,2
        \\4,5
        \\3,0
        \\2,1
        \\6,3
        \\2,4
        \\1,5
        \\0,6
        \\3,3
        \\2,6
        \\5,1
        \\1,2
        \\5,5
        \\2,5
        \\6,5
        \\1,4
        \\0,4
        \\6,4
        \\1,1
        \\6,1
        \\1,0
        \\0,5
        \\1,6
        \\2,0
    , 6, 6, 13);
    try std.testing.expectEqual(6001, result);
}
