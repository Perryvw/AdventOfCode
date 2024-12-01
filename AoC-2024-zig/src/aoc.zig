const std = @import("std");
const common = @import("common.zig");

pub const Answer = union(enum) { i: u64, str: []const u8 };
pub const Answers = struct {
    p1: Answer,
    p2: Answer,
};
const Solver = *const fn () anyerror!Answers;
const SolverWithData = *const fn (data: []const u8) anyerror!Answers;
const RunResult = struct {
    answers: Answers,
    avg_time: i64,
    min_time: i64,
    max_time: i64,
};

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
    //@import("day2.zig").solution,
};

pub fn main() !void {
    for (answers, 1..) |s, day| {
        const result = try runSolution(s);
        std.log.info("Day {}: p1: {s}, p2: {s}, min: {s}, max: {s}, mean: {s} ({} iterations)", .{
            day,
            try printAnswer(result.answers.p1),
            try printAnswer(result.answers.p2),
            try formatDurationMs(result.min_time),
            try formatDurationMs(result.max_time),
            try formatDurationMs(result.avg_time),
            ITERATIONS,
        });
    }
}

inline fn formatDurationMs(micros: i64) ![]const u8 {
    var buf: [20]u8 = undefined;
    return try std.fmt.bufPrint(&buf, "{}.{} ms", .{
        @divFloor(micros, 1000),
        @rem(micros, 1000),
    });
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

    var buf: [300 * 1024]u8 = undefined;

    const size = try in_stream.readAll(&buf);
    const str = buf[0..size];

    return str;
}

fn runSolution(solution: Solution) !RunResult {
    var data: ?[]const u8 = null;

    const result = switch (solution) {
        .Func => |f| try f(),
        .WithData => |dataSolver| blk: {
            data = try readFile(dataSolver.data);
            break :blk try dataSolver.solve(data.?);
        },
    };

    const runDurations = try benchmark(solution, data, ITERATIONS);
    const min_time = common.min(i64, runDurations);
    const avg_time = common.avg(i64, runDurations);
    const max_time = common.max(i64, runDurations);

    return .{
        .answers = result,
        .min_time = min_time,
        .max_time = max_time,
        .avg_time = avg_time,
    };
}

fn benchmark(action: Solution, data: ?[]const u8, iteratations: comptime_int) ![]i64 {
    var result: [iteratations]i64 = undefined;

    for (0..iteratations) |i| {
        var start: i64 = 0;
        var end: i64 = 0;
        while (start == end) { // sometimes it just decides the thing took 0 us? not sure how or why
            start = std.time.microTimestamp();
            if (data) |d| {
                std.mem.doNotOptimizeAway(try action.WithData.solve(d));
            } else {
                std.mem.doNotOptimizeAway(try action.Func());
            }
            end = std.time.microTimestamp();
        }
        result[i] = end - start;
    }

    return &result;
}
