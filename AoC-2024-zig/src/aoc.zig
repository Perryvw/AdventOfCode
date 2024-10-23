const std = @import("std");
const common = @import("common.zig");

pub const Answer = union(enum) { i: u64, str: []const u8 };
const Solver = *const fn () anyerror!Answer;
const SolverWithData = *const fn (data: []const u8) anyerror!Answer;
const RunResult = struct { answer: Answer, avg_time: i64 };

pub const Solution = union(enum) {
    Func: Solver,
    WithData: struct {
        data: []const u8,
        solve: SolverWithData,
    },
};

const ITERATIONS = 1000;

// Add new days to run here
const answers = [_]Solution{
    @import("day1.zig").solution,
    @import("day2.zig").solution,
};

pub fn main() !void {
    for (answers, 1..) |s, day| {
        const result = try runSolution(s);
        std.log.info("Day {}: answer: {s}, duration: {}.{} ms ({} iterations)", .{ day, try printAnswer(result.answer), @divFloor(result.avg_time, 1000), @rem(result.avg_time, 1000), ITERATIONS });
    }
}

inline fn printAnswer(a: Answer) ![]const u8 {
    return switch (a) {
        .i => |i| {
            var buf: [20]u8 = undefined;
            return try std.fmt.bufPrint(&buf, "{}", .{i});
        },
        .str => |s| s,
    };
}

fn readFile(filename: []const u8) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const in_stream = buf_reader.reader();

    var buf: [30 * 1024]u8 = undefined;

    const size = try in_stream.readAll(&buf);
    const str = buf[0..size];

    return str;
}

fn runSolution(solution: Solution) !RunResult {
    var data: ?[]const u8 = null;

    const answer = switch (solution) {
        .Func => |f| try f(),
        .WithData => |dataSolver| blk: {
            data = try readFile(dataSolver.data);
            break :blk try dataSolver.solve(data.?);
        },
    };

    const runDurations = try benchmark(solution, data, ITERATIONS);
    const avg_time = common.avg(i64, runDurations);

    return .{ .answer = answer, .avg_time = avg_time };
}

fn benchmark(action: Solution, data: ?[]const u8, iteratations: comptime_int) ![]i64 {
    var result: [iteratations]i64 = undefined;

    for (0..iteratations) |i| {
        const start = std.time.microTimestamp();
        if (data) |d| {
            std.mem.doNotOptimizeAway(try action.WithData.solve(d));
        } else {
            std.mem.doNotOptimizeAway(try action.Func());
        }
        const end = std.time.microTimestamp();
        result[i] = end - start;
    }

    return &result;
}
