const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day21.txt",
    .solve = &solve,
    .benchmarkIterations = 100,
} };

const MemoMap = [27]std.StringHashMap(u64);

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var tableP1 = std.AutoHashMap(Key, u64).init(allocator);
    defer tableP1.deinit();

    var tableP2 = std.AutoHashMap(Key, u64).init(allocator);
    defer tableP2.deinit();

    try fillDynamicProgrammingTable(allocator, 3, &tableP1);
    try fillDynamicProgrammingTable(allocator, 26, &tableP2);

    var p1: u64 = 0;
    var p2: u64 = 0;
    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |code| {
        const numericPart = common.parseInt(u32, code[0 .. code.len - 1]);
        p1 += numericPart * fewestPresses(3, &tableP1, code);
        p2 += numericPart * fewestPresses(26, &tableP2, code);
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn keyPosLarge(k: u8) common.Coord {
    return switch (k) {
        '7' => .{ .x = 0, .y = 0 },
        '8' => .{ .x = 1, .y = 0 },
        '9' => .{ .x = 2, .y = 0 },
        '4' => .{ .x = 0, .y = 1 },
        '5' => .{ .x = 1, .y = 1 },
        '6' => .{ .x = 2, .y = 1 },
        '1' => .{ .x = 0, .y = 2 },
        '2' => .{ .x = 1, .y = 2 },
        '3' => .{ .x = 2, .y = 2 },
        ' ' => .{ .x = 0, .y = 3 },
        '0' => .{ .x = 1, .y = 3 },
        'A' => .{ .x = 2, .y = 3 },
        else => @panic("unknown key!"),
    };
}

fn keyPosSmall(k: u8) common.Coord {
    return switch (k) {
        ' ' => .{ .x = 0, .y = 0 },
        '^' => .{ .x = 1, .y = 0 },
        'A' => .{ .x = 2, .y = 0 },
        '<' => .{ .x = 0, .y = 1 },
        'v' => .{ .x = 1, .y = 1 },
        '>' => .{ .x = 2, .y = 1 },
        else => @panic("unknown key!"),
    };
}

const Key = struct {
    level: usize,
    from: u8,
    to: u8,
};

fn fewestPresses(level: usize, table: *std.AutoHashMap(Key, u64), seq: []const u8) u64 {
    var current: u8 = 'A';
    var result: u64 = 0;
    for (seq) |next| {
        result += table.get(.{ .from = current, .to = next, .level = level }).?;
        current = next;
    }
    return result;
}

const LEFTS = "<<<<<<<<<<<<<<<<";
const RIGHTS = ">>>>>>>>>>>>>>>>";
const UPS = "^^^^^^^^^^^^^^^^";
const DOWNS = "vvvvvvvvvvvv";

fn fillDynamicProgrammingTable(allocator: std.mem.Allocator, levels: usize, table: *std.AutoHashMap(Key, u64)) !void {
    for ("^A<v>") |c1| {
        for ("^A<v>") |c2| {
            try table.put(.{ .from = c1, .to = c2, .level = 0 }, 1);
        }
    }

    for (1..levels + 1) |layer| {
        if (layer == levels) {
            for (" 0123456789A") |c1| {
                for (" 0123456789A") |c2| {
                    const p1 = keyPosLarge(c1);
                    const p2 = keyPosLarge(c2);
                    const diff = p1.diff(p2);

                    var seqHor = try allocator.alloc(u8, @abs(diff.x) + @abs(diff.y) + 1);
                    defer allocator.free(seqHor);
                    var seqVert = try allocator.alloc(u8, @abs(diff.x) + @abs(diff.y) + 1);
                    defer allocator.free(seqVert);

                    std.mem.copyForwards(u8, seqHor, if (diff.x < 0) RIGHTS[0..@abs(diff.x)] else LEFTS[0..@intCast(diff.x)]);
                    std.mem.copyForwards(u8, seqHor[@abs(diff.x)..], if (diff.y < 0) DOWNS[0..@abs(diff.y)] else UPS[0..@intCast(diff.y)]);
                    seqHor[seqHor.len - 1] = 'A';

                    std.mem.copyForwards(u8, seqVert, if (diff.y < 0) DOWNS[0..@abs(diff.y)] else UPS[0..@intCast(diff.y)]);
                    std.mem.copyForwards(u8, seqVert[@abs(diff.y)..], if (diff.x < 0) RIGHTS[0..@abs(diff.x)] else LEFTS[0..@intCast(diff.x)]);
                    seqVert[seqVert.len - 1] = 'A';

                    var fewestHorizontal = fewestPresses(layer - 1, table, seqHor);
                    var fewestVertical = fewestPresses(layer - 1, table, seqVert);

                    const illegal = keyPosLarge(' ');
                    if (p1.x == illegal.x and p2.y == illegal.y) fewestVertical = std.math.maxInt(u64);
                    if (p2.x == illegal.x and p1.y == illegal.y) fewestHorizontal = std.math.maxInt(u64);

                    try table.put(.{ .from = c1, .to = c2, .level = layer }, @min(fewestHorizontal, fewestVertical));
                }
            }
        } else {
            for (" ^A<v>") |c1| {
                for (" ^A<v>") |c2| {
                    const p1 = keyPosSmall(c1);
                    const p2 = keyPosSmall(c2);
                    const diff = p1.diff(p2);

                    var seqHor = try allocator.alloc(u8, @abs(diff.x) + @abs(diff.y) + 1);
                    defer allocator.free(seqHor);
                    var seqVert = try allocator.alloc(u8, @abs(diff.x) + @abs(diff.y) + 1);
                    defer allocator.free(seqVert);

                    std.mem.copyForwards(u8, seqHor, if (diff.x < 0) RIGHTS[0..@abs(diff.x)] else LEFTS[0..@intCast(diff.x)]);
                    std.mem.copyForwards(u8, seqHor[@abs(diff.x)..], if (diff.y < 0) DOWNS[0..@abs(diff.y)] else UPS[0..@intCast(diff.y)]);
                    seqHor[seqHor.len - 1] = 'A';

                    std.mem.copyForwards(u8, seqVert, if (diff.y < 0) DOWNS[0..@abs(diff.y)] else UPS[0..@intCast(diff.y)]);
                    std.mem.copyForwards(u8, seqVert[@abs(diff.y)..], if (diff.x < 0) RIGHTS[0..@abs(diff.x)] else LEFTS[0..@intCast(diff.x)]);
                    seqVert[seqVert.len - 1] = 'A';

                    var fewestHorizontal = fewestPresses(layer - 1, table, seqHor);
                    var fewestVertical = fewestPresses(layer - 1, table, seqVert);

                    const illegal = keyPosSmall(' ');
                    if (p1.x == illegal.x and p2.y == illegal.y) fewestVertical = std.math.maxInt(u64);
                    if (p2.x == illegal.x and p1.y == illegal.y) fewestHorizontal = std.math.maxInt(u64);

                    try table.put(.{ .from = c1, .to = c2, .level = layer }, @min(fewestHorizontal, fewestVertical));
                }
            }
        }
    }
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\029A
        \\980A
        \\179A
        \\456A
        \\379A
    );
    try std.testing.expectEqual(126384, result.p1.i);
    try std.testing.expectEqual(154115708116294, result.p2.i);
}
