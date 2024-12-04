const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day4.txt",
    .solve = &solve,
} };

const Grid = struct {
    data: []const u8,
    width: usize,
    height: usize,

    fn charAtPosition(self: *const Grid, x: i32, y: i32, c: u8) bool {
        if (x < 0 or x >= self.width) return false;
        if (y < 0 or y >= self.height) return false;
        return self.data[self.pos(x, y)] == c;
    }

    inline fn pos(self: *const Grid, x: i32, y: i32) usize {
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

    const width = std.mem.indexOf(u8, data, "\n").?;
    const height = @divTrunc(data.len, width);

    const grid: Grid = .{ .data = data, .width = width, .height = height };

    for (0..width) |ux| {
        for (0..height) |uy| {
            const x: i32 = @intCast(ux);
            const y: i32 = @intCast(uy);
            if (grid.charAtPosition(x, y, 'X')) {
                // Horizontal
                if (grid.charAtPosition(x + 1, y, 'M') and grid.charAtPosition(x + 2, y, 'A') and grid.charAtPosition(x + 3, y, 'S')) {
                    p1 += 1;
                }
                // Horizontal reverse
                if (grid.charAtPosition(x - 1, y, 'M') and grid.charAtPosition(x - 2, y, 'A') and grid.charAtPosition(x - 3, y, 'S')) {
                    p1 += 1;
                }
                // Vertical
                if (grid.charAtPosition(x, y + 1, 'M') and grid.charAtPosition(x, y + 2, 'A') and grid.charAtPosition(x, y + 3, 'S')) {
                    p1 += 1;
                }
                // Vertical reverse
                if (grid.charAtPosition(x, y - 1, 'M') and grid.charAtPosition(x, y - 2, 'A') and grid.charAtPosition(x, y - 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal
                if (grid.charAtPosition(x + 1, y + 1, 'M') and grid.charAtPosition(x + 2, y + 2, 'A') and grid.charAtPosition(x + 3, y + 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse
                if (grid.charAtPosition(x - 1, y - 1, 'M') and grid.charAtPosition(x - 2, y - 2, 'A') and grid.charAtPosition(x - 3, y - 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse2
                if (grid.charAtPosition(x - 1, y + 1, 'M') and grid.charAtPosition(x - 2, y + 2, 'A') and grid.charAtPosition(x - 3, y + 3, 'S')) {
                    p1 += 1;
                }
                // Diagonal reverse3
                if (grid.charAtPosition(x + 1, y - 1, 'M') and grid.charAtPosition(x + 2, y - 2, 'A') and grid.charAtPosition(x + 3, y - 3, 'S')) {
                    p1 += 1;
                }
            } else if (grid.charAtPosition(x, y, 'A')) {
                if (grid.charAtPosition(x - 1, y - 1, 'M') and grid.charAtPosition(x - 1, y + 1, 'M') and grid.charAtPosition(x + 1, y - 1, 'S') and grid.charAtPosition(x + 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.charAtPosition(x - 1, y - 1, 'M') and grid.charAtPosition(x + 1, y - 1, 'M') and grid.charAtPosition(x - 1, y + 1, 'S') and grid.charAtPosition(x + 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.charAtPosition(x + 1, y - 1, 'M') and grid.charAtPosition(x + 1, y + 1, 'M') and grid.charAtPosition(x - 1, y - 1, 'S') and grid.charAtPosition(x - 1, y + 1, 'S')) {
                    p2 += 1;
                } else if (grid.charAtPosition(x - 1, y + 1, 'M') and grid.charAtPosition(x + 1, y + 1, 'M') and grid.charAtPosition(x + 1, y - 1, 'S') and grid.charAtPosition(x - 1, y - 1, 'S')) {
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
    const result = try solve(
        \\..X...
        \\.SAMX.
        \\.A..A.
        \\XMAS.S
        \\.X....
    );
    try std.testing.expectEqual(4, result.p1.i);
}

test "example" {
    const result = try solve(
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
