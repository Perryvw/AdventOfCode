const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day13.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    p1 = 0;
    p2 = 0;

    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |lineA| {
        const lineB = iter.next().?;
        const linePrize = iter.next().?;

        const aX, const aY = parseButton(lineA);
        const bX, const bY = parseButton(lineB);
        const prizeX, const prizeY = parsePrize(linePrize);

        if (solveEquationSystem(aX, aY, bX, bY, prizeX, prizeY)) |counts| {
            p1 += @intCast(3 * counts.A + counts.B);
        }

        if (solveEquationSystem(aX, aY, bX, bY, prizeX + 10000000000000, prizeY + 10000000000000)) |counts| {
            p2 += @intCast(3 * counts.A + counts.B);
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn solveEquationSystem(aX: i64, aY: i64, bX: i64, bY: i64, prizeX: i64, prizeY: i64) ?struct { A: i64, B: i64 } {
    const numeratorA = bY * prizeX - bX * prizeY;
    const denominatorA = aX * bY - aY * bX;
    const numeratorB = -aY * prizeX + aX * prizeY;
    const denominatorB = aX * bY - aY * bX;

    if (@mod(numeratorA, denominatorA) == 0 and @mod(numeratorB, denominatorB) == 0) {
        const kA = @divExact(numeratorA, denominatorA);
        const kB = @divExact(numeratorB, denominatorB);

        return .{ .A = kA, .B = kB };
    }

    return null;
}

fn parseButton(line: []const u8) std.meta.Tuple(&.{ i64, i64 }) {
    const index1 = std.mem.indexOfScalar(u8, line, '+').?;
    const comma = std.mem.indexOfScalar(u8, line[index1..], ',').? + index1;
    const index2 = std.mem.indexOfScalar(u8, line[comma..], '+').? + comma;

    return .{
        common.parseInt(i64, line[(index1 + 1)..comma]),
        common.parseInt(i64, line[(index2 + 1)..]),
    };
}

fn parsePrize(line: []const u8) std.meta.Tuple(&.{ i64, i64 }) {
    const index1 = std.mem.indexOfScalar(u8, line, '=').?;
    const comma = std.mem.indexOfScalar(u8, line[index1..], ',').? + index1;
    const index2 = std.mem.indexOfScalar(u8, line[comma..], '=').? + comma;

    return .{
        common.parseInt(i64, line[(index1 + 1)..comma]),
        common.parseInt(i64, line[(index2 + 1)..]),
    };
}

test "example" {
    const result = try solve(
        \\Button A: X+94, Y+34
        \\Button B: X+22, Y+67
        \\Prize: X=8400, Y=5400
        \\
        \\Button A: X+26, Y+66
        \\Button B: X+67, Y+21
        \\Prize: X=12748, Y=12176
        \\
        \\Button A: X+17, Y+86
        \\Button B: X+84, Y+37
        \\Prize: X=7870, Y=6450
        \\
        \\Button A: X+69, Y+23
        \\Button B: X+27, Y+71
        \\Prize: X=18641, Y=10279
    );
    try std.testing.expectEqual(480, result.p1.i);
    try std.testing.expectEqual(875318608908, result.p2.i);
}
