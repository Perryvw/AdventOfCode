const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day4.txt",
    .solve = &solve,
} };

fn solve(_: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: i32 = 0;
    var p2: i32 = 0;

    const grid = common.ImmutableGrid.init(data);

    for (0..grid.width) |ux| {
        for (0..grid.height) |uy| {
            const x: i32 = @intCast(ux);
            const y: i32 = @intCast(uy);
            if (grid.isCharAtPosition(x, y, 'X')) {
                // Horizontal
                if (grid.isCharAtPosition(x + 1, y, 'M') and grid.isCharAtPosition(x + 2, y, 'A') and grid.isCharAtPosition(x + 3, y, 'S')) {
                    p1 += 1;
                }
                // Horizontal reverse
                if (grid.isCharAtPosition(x - 1, y, 'M') and grid.isCharAtPosition(x - 2, y, 'A') and grid.isCharAtPosition(x - 3, y, 'S')) {
                    p1 += 1;
                }
                // Vertical
                if (grid.isCharAtPosition(x, y + 1, 'M') and grid.isCharAtPosition(x, y + 2, 'A') and grid.isCharAtPosition(x, y + 3, 'S')) {
                    p1 += 1;
                }
                // Vertical reverse
                if (grid.isCharAtPosition(x, y - 1, 'M') and grid.isCharAtPosition(x, y - 2, 'A') and grid.isCharAtPosition(x, y - 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal
                if (grid.isCharAtPosition(x + 1, y + 1, 'M') and grid.isCharAtPosition(x + 2, y + 2, 'A') and grid.isCharAtPosition(x + 3, y + 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse
                if (grid.isCharAtPosition(x - 1, y - 1, 'M') and grid.isCharAtPosition(x - 2, y - 2, 'A') and grid.isCharAtPosition(x - 3, y - 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse2
                if (grid.isCharAtPosition(x - 1, y + 1, 'M') and grid.isCharAtPosition(x - 2, y + 2, 'A') and grid.isCharAtPosition(x - 3, y + 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse3
                if (grid.isCharAtPosition(x + 1, y - 1, 'M') and grid.isCharAtPosition(x + 2, y - 2, 'A') and grid.isCharAtPosition(x + 3, y - 3, 'S')) {
                    p1 += 1;
                }
            } else if (grid.isCharAtPosition(x, y, 'A')) {
                if (grid.isCharAtPosition(x - 1, y - 1, 'M') and grid.isCharAtPosition(x - 1, y + 1, 'M') and grid.isCharAtPosition(x + 1, y - 1, 'S') and grid.isCharAtPosition(x + 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.isCharAtPosition(x - 1, y - 1, 'M') and grid.isCharAtPosition(x + 1, y - 1, 'M') and grid.isCharAtPosition(x - 1, y + 1, 'S') and grid.isCharAtPosition(x + 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.isCharAtPosition(x + 1, y - 1, 'M') and grid.isCharAtPosition(x + 1, y + 1, 'M') and grid.isCharAtPosition(x - 1, y - 1, 'S') and grid.isCharAtPosition(x - 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.isCharAtPosition(x - 1, y + 1, 'M') and grid.isCharAtPosition(x + 1, y + 1, 'M') and grid.isCharAtPosition(x + 1, y - 1, 'S') and grid.isCharAtPosition(x - 1, y - 1, 'S')) {
                    p2 += 1;
                }
            }
        }
    }

    return .{
        .p1 = .{ .i = @intCast(p1) },
        .p2 = .{ .i = @intCast(p2) },
    };
}

test "small example" {
    const result = try solve(std.testing.allocator,
        \\..X...
        \\.SAMX.
        \\.A..A.
        \\XMAS.S
        \\.X....
    );
    try std.testing.expectEqual(4, result.p1.i);
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    );
    try std.testing.expectEqual(18, result.p1.i);
    try std.testing.expectEqual(9, result.p2.i);
}
