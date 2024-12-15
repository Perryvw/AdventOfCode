const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day15.txt",
    .solve = &solve,
} };

fn solve(data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    p2 = 0;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    const halfway = std.mem.indexOf(u8, data, "\n\n").?;
    const inpLayout = data[0..halfway];
    const inpInstructions = data[(halfway + 1)..];

    const gridData = try allocator.alloc(u8, inpLayout.len);
    defer allocator.free(gridData);
    @memcpy(gridData, inpLayout);

    var p2GridData = try allocator.alloc(u8, inpLayout.len * 2 + 1);
    defer allocator.free(p2GridData);
    for (inpLayout, 0..) |c, i| {
        switch (c) {
            '#' => {
                p2GridData[i * 2] = '#';
                p2GridData[i * 2 + 1] = '#';
            },
            'O' => {
                p2GridData[i * 2] = '[';
                p2GridData[i * 2 + 1] = ']';
            },
            '.' => {
                p2GridData[i * 2] = '.';
                p2GridData[i * 2 + 1] = '.';
            },
            '@' => {
                p2GridData[i * 2] = '@';
                p2GridData[i * 2 + 1] = '.';
            },
            '\n' => {
                p2GridData[i * 2] = '#';
                p2GridData[i * 2 + 1] = '\n';
            },
            else => @panic("invalid grid cell!"),
        }
    }

    var grid = common.Grid.fromString(gridData);
    var grid2 = common.Grid.fromString(p2GridData);

    var robotPos = grid.find('@').?;
    var robotPos2 = grid2.find('@').?;

    var iter = std.mem.tokenizeScalar(u8, inpInstructions, '\n');
    while (iter.next()) |line| {
        for (line) |instruction| {
            robotPos = move(robotPos.x, robotPos.y, instruction, &grid);
            robotPos2 = move(robotPos2.x, robotPos2.y, instruction, &grid2);
        }
    }

    p1 = score(&grid);
    p2 = score(&grid2);

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn move(robotX: i32, robotY: i32, instruction: u8, grid: *common.Grid) common.Coord {
    switch (instruction) {
        '^' => return moveVertical(robotX, robotY, -1, grid),
        '>' => return moveHorizontal(robotX, robotY, 1, grid),
        'v' => return moveVertical(robotX, robotY, 1, grid),
        '<' => return moveHorizontal(robotX, robotY, -1, grid),
        else => @panic("Incorrect instruction!"),
    }
}

fn moveHorizontal(robotX: i32, robotY: i32, direction: i32, grid: *common.Grid) common.Coord {
    if (canMoveHorizontal(robotX, robotY, direction, grid)) {
        doMoveHorizontal(robotX, robotY, direction, grid);
        return .{
            .x = robotX + direction,
            .y = robotY,
        };
    }

    return .{
        .x = robotX,
        .y = robotY,
    };
}

fn doMoveHorizontal(x: i32, y: i32, direction: i32, grid: *common.Grid) void {
    switch (grid.charAtPos(x + direction, y).?) {
        '.' => {
            grid.data[grid.pos(x + direction, y)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        'O' => {
            doMoveHorizontal(x + direction, y, direction, grid);
            grid.data[grid.pos(x + direction, y)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        '[' => {
            doMoveHorizontal(x + 2, y, direction, grid);
            grid.data[grid.pos(x + 2, y)] = grid.data[grid.pos(x + 1, y)];
            grid.data[grid.pos(x + 1, y)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        ']' => {
            doMoveHorizontal(x - 2, y, direction, grid);
            grid.data[grid.pos(x - 2, y)] = grid.data[grid.pos(x - 1, y)];
            grid.data[grid.pos(x - 1, y)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        else => @panic("invalid move!"),
    }
}

fn moveVertical(robotX: i32, robotY: i32, direction: i32, grid: *common.Grid) common.Coord {
    if (canMoveVertical(robotX, robotY, direction, grid)) {
        doMoveVertical(robotX, robotY, direction, grid);
        return .{
            .x = robotX,
            .y = robotY + direction,
        };
    }

    return .{
        .x = robotX,
        .y = robotY,
    };
}

fn doMoveVertical(x: i32, y: i32, direction: i32, grid: *common.Grid) void {
    switch (grid.charAtPos(x, y + direction).?) {
        '.' => {
            grid.data[grid.pos(x, y + direction)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        'O' => {
            doMoveVertical(x, y + direction, direction, grid);
            grid.data[grid.pos(x, y + direction)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        '[' => {
            doMoveVertical(x, y + direction, direction, grid);
            doMoveVertical(x + 1, y + direction, direction, grid);
            grid.data[grid.pos(x, y + direction)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        ']' => {
            doMoveVertical(x, y + direction, direction, grid);
            doMoveVertical(x - 1, y + direction, direction, grid);
            grid.data[grid.pos(x, y + direction)] = grid.data[grid.pos(x, y)];
            grid.data[grid.pos(x, y)] = '.';
        },
        else => @panic("invalid move!"),
    }
}

fn canMoveHorizontal(x: i32, y: i32, direction: i32, grid: *common.Grid) bool {
    return switch (grid.charAtPos(x + direction, y).?) {
        '#' => false,
        '.' => true,
        'O' => canMoveHorizontal(x + direction, y, direction, grid),
        '[' => canMoveHorizontal(x + 2, y, direction, grid),
        ']' => canMoveHorizontal(x - 2, y, direction, grid),
        else => @panic("unknown grid cell!"),
    };
}

fn canMoveVertical(x: i32, y: i32, direction: i32, grid: *common.Grid) bool {
    return switch (grid.charAtPos(x, y + direction).?) {
        '#' => false,
        '.' => true,
        'O' => canMoveVertical(x, y + direction, direction, grid),
        '[' => canMoveVertical(x, y + direction, direction, grid) and canMoveVertical(x + 1, y + direction, direction, grid),
        ']' => canMoveVertical(x, y + direction, direction, grid) and canMoveVertical(x - 1, y + direction, direction, grid),
        else => @panic("unknown grid cell!"),
    };
}

fn score(grid: *common.Grid) u64 {
    var s: u64 = 0;
    for (0..grid.height) |y| {
        for (0..grid.width) |x| {
            if (grid.isCharAtPosition(@intCast(x), @intCast(y), 'O') or grid.isCharAtPosition(@intCast(x), @intCast(y), '[')) {
                s += y * 100 + x;
            }
        }
    }
    return s;
}

test "example" {
    const result = try solve(
        \\##########
        \\#..O..O.O#
        \\#......O.#
        \\#.OO..O.O#
        \\#..O@..O.#
        \\#O#..O...#
        \\#O..O..O.#
        \\#.OO.O.OO#
        \\#....O...#
        \\##########
        \\
        \\<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
        \\vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
        \\><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
        \\<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
        \\^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
        \\^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
        \\>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
        \\<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
        \\^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
        \\v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
    );
    try std.testing.expectEqual(10092, result.p1.i);
    try std.testing.expectEqual(9021, result.p2.i);
}

test "smaller example" {
    const result = try solve(
        \\########
        \\#..O.O.#
        \\##@.O..#
        \\#...O..#
        \\#.#.O..#
        \\#...O..#
        \\#......#
        \\########
        \\
        \\<^^>>>vv<v>>v<<
    );
    try std.testing.expectEqual(2028, result.p1.i);
}

test "p2" {
    const result = try solve(
        \\#######
        \\#...#.#
        \\#.....#
        \\#..OO@#
        \\#..O..#
        \\#.....#
        \\#######
        \\
        \\<vv<<^^<<^^
    );
    try std.testing.expectEqual(618, result.p2.i);
}
