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
    @import("day2.zig").solution,
    @import("day3.zig").solution,
    @import("day4.zig").solution,
    @import("day5.zig").solution,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    for (answers, 1..) |s, day| {
        const result = try runSolution(s, allocator);
        std.debug.print("Day {}: p1: {s}, p2: {s}, min: {d}, max: {d}, mean: {d} ({} iterations)\n", .{
            day,
            try printAnswer(result.answers.p1),
            try printAnswer(result.answers.p2),
            @as(f64, @floatFromInt(result.min_time)) / 1000.0,
            @as(f64, @floatFromInt(result.max_time)) / 1000.0,
            @as(f64, @floatFromInt(result.avg_time)) / 1000.0,
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

fn readFile(filename: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    return try file.readToEndAlloc(allocator, 1024 * 1024);
}

fn runSolution(solution: Solution, allocator: std.mem.Allocator) !RunResult {
    var data: ?[]const u8 = null;

    const result = switch (solution) {
        .Func => |f| try f(),
        .WithData => |dataSolver| blk: {
            data = try readFile(dataSolver.data, allocator);
            break :blk try dataSolver.solve(data.?);
        },
    };

    const runDurations = try benchmark(solution, data, ITERATIONS);
    const min_time = common.min(i64, runDurations);
    const avg_time = common.avg(i64, runDurations);
    const max_time = common.max(i64, runDurations);

    if (data) |d| {
        allocator.free(d);
    }

    return .{
        .answers = result,
        .min_time = min_time,
        .max_time = max_time,
        .avg_time = avg_time,
    };
}

fn benchmark(action: Solution, data: ?[]const u8, iteratations: comptime_int) ![]i64 {
    var result: [iteratations]i64 = undefined;
    var timer = try std.time.Timer.start();

    if (data) |d| {
        for (0..iteratations) |i| {
            const start = timer.read();
            std.mem.doNotOptimizeAway(try action.WithData.solve(d));
            const end = timer.lap();
            result[i] = @intCast(@divTrunc(end - start, 1000));
        }
    } else {
        for (0..iteratations) |i| {
            const start = timer.read();
            std.mem.doNotOptimizeAway(try action.Func());
            const end = timer.lap();
            result[i] = @intCast(@divTrunc(end - start, 1000));
        }
    }

    return &result;
}
