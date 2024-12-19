const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day14.txt",
    .solve = &solve,
    .benchmarkIterations = 10,
} };

const Coord = struct { x: i32, y: i32 };
const Robot = struct { pos: Coord, vel: Coord };

const STEPS = 100;

fn solve(_: std.mem.Allocator, data: []const u8) !aoc.Answers {
    const BATHROOM_WIDTH = 101;
    const BATHROOM_HEIGHT = 103;
    return solve2(data, BATHROOM_WIDTH, BATHROOM_HEIGHT);
}

fn solve2(data: []const u8, roomWidth: i32, roomHeight: i32) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    var robots: [500]Robot = undefined;
    var numRobots: usize = 0;

    var iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (iter.next()) |line| {
        robots[numRobots] = parseRobot(line);
        numRobots += 1;
    }

    for (0..STEPS) |_| {
        for (robots[0..numRobots]) |*robot| {
            robot.pos.x = @mod(robot.pos.x + robot.vel.x, roomWidth);
            robot.pos.y = @mod(robot.pos.y + robot.vel.y, roomHeight);
        }
    }

    p1 = countQuadrants(robots[0..numRobots], roomWidth, roomHeight);

    if (roomHeight > 100) {
        var i: usize = 100; // starting after the 100 steps taken in p1
        while (p2 == 0) outer: {
            var buf = std.mem.zeroes([101 * 103]bool);
            for (robots[0..numRobots]) |robot| {
                buf[@intCast(robot.pos.y * roomWidth + robot.pos.x)] = true;
            }

            for (0..@intCast(roomHeight)) |y| {
                if (std.mem.indexOf(bool, buf[(y * @as(usize, @intCast(roomWidth)))..((y + 1) * @as(usize, @intCast(roomWidth)))], &.{ true, true, true, true, true, true, true, true, true }) != null) {
                    p2 = i;
                    break :outer;
                }
            }

            for (robots[0..numRobots]) |*robot| {
                robot.pos.x = @mod(robot.pos.x + robot.vel.x, roomWidth);
                robot.pos.y = @mod(robot.pos.y + robot.vel.y, roomHeight);
            }
            i += 1;
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn parseRobot(line: []const u8) Robot {
    const velStart = std.mem.indexOf(u8, line, " v=").?;
    const pos = parseCoord(line[2..velStart]);
    const vel = parseCoord(line[(velStart + 3)..]);

    return .{
        .pos = pos,
        .vel = vel,
    };
}

fn parseCoord(line: []const u8) Coord {
    const comma = std.mem.indexOfScalar(u8, line, ',').?;
    return .{
        .x = common.parseInt(i32, line[0..comma]),
        .y = common.parseInt(i32, line[(comma + 1)..]),
    };
}

fn countQuadrants(robots: []const Robot, roomWidth: i32, roomHeight: i32) u64 {
    const midX = @divTrunc(roomWidth, 2);
    const midY = @divTrunc(roomHeight, 2);

    var quadrants = [4]u32{ 0, 0, 0, 0 };

    for (robots) |robot| {
        if (robot.pos.x < midX and robot.pos.y < midY) {
            quadrants[0] += 1;
        } else if (robot.pos.x > midX and robot.pos.y < midY) {
            quadrants[1] += 1;
        } else if (robot.pos.x > midX and robot.pos.y > midY) {
            quadrants[2] += 1;
        } else if (robot.pos.x < midX and robot.pos.y > midY) {
            quadrants[3] += 1;
        }
    }
    return quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3];
}

test "example" {
    const result = try solve2(
        \\p=0,4 v=3,-3
        \\p=6,3 v=-1,-3
        \\p=10,3 v=-1,2
        \\p=2,0 v=2,-1
        \\p=0,0 v=1,3
        \\p=3,0 v=-2,-2
        \\p=7,6 v=-1,-3
        \\p=3,0 v=-1,-2
        \\p=9,3 v=2,3
        \\p=7,3 v=-1,2
        \\p=2,4 v=2,-3
        \\p=9,5 v=-3,-3
    , 11, 7);
    try std.testing.expectEqual(12, result.p1.i);
}
