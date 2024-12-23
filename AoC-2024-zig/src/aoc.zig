const std = @import("std");
const common = @import("common.zig");

pub const Answer = union(enum) { i: u64, str: []const u8 };
pub const Answers = struct {
    p1: Answer,
    p2: Answer,

    pub fn deinit(self: *const Answers, allocator: std.mem.Allocator) void {
        switch (self.p1) {
            .i => |_| {},
            .str => |s| allocator.free(s),
        }
        switch (self.p2) {
            .i => |_| {},
            .str => |s| allocator.free(s),
        }
    }
};
const Solver = *const fn (allocator: std.mem.Allocator) anyerror!Answers;
const SolverWithData = *const fn (allocator: std.mem.Allocator, data: []const u8) anyerror!Answers;
const RunResult = struct {
    answers: Answers,
    avg_time: i64,
    min_time: i64,
    max_time: i64,
    std_dev_time: f64,
};

const DEFAULT_ITERATIONS = 1000;

pub const Solution = union(enum) {
    Func: struct {
        solve: Solver,
        benchmarkIterations: u32 = DEFAULT_ITERATIONS,
    },
    WithData: struct {
        data: []const u8,
        solve: SolverWithData,
        benchmarkIterations: u32 = DEFAULT_ITERATIONS,
    },
};

// Add new days to run here
const answers = [_]Solution{
    @import("day1.zig").solution,
    @import("day2.zig").solution,
    @import("day3.zig").solution,
    @import("day4.zig").solution,
    @import("day5.zig").solution,
    @import("day6.zig").solution,
    @import("day7.zig").solution,
    @import("day8.zig").solution,
    @import("day9.zig").solution,
    @import("day10.zig").solution,
    @import("day11.zig").solution,
    @import("day12.zig").solution,
    @import("day13.zig").solution,
    @import("day14.zig").solution,
    @import("day15.zig").solution,
    @import("day16.zig").solution,
    @import("day17.zig").solution,
    @import("day18.zig").solution,
    @import("day19.zig").solution,
    @import("day20.zig").solution,
    @import("day21.zig").solution,
    @import("day22.zig").solution,
    @import("day23.zig").solution,
};

pub fn main() !void {
    _ = std.os.windows.kernel32.SetConsoleOutputCP(65001); // Fix unicode in output

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    for (answers, 1..) |s, day| {
        const result = try runSolution(s, allocator);
        defer result.answers.deinit(allocator);
        std.debug.print("Day {: <2}: p1: {s: <17} p2: {s: <16} {d: <8} ms ± σ {d: <7.3} ({} iterations)\n", .{
            day,
            try printAnswer(result.answers.p1),
            try printAnswer(result.answers.p2),
            @as(f64, @floatFromInt(result.avg_time)) / 1000.0,
            result.std_dev_time / 1000.0,
            benchmarkIterations(s),
        });
    }
}

fn benchmarkIterations(s: Solution) u32 {
    return switch (s) {
        .Func => |t| t.benchmarkIterations,
        .WithData => |t| t.benchmarkIterations,
    };
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
        .Func => |f| try f.solve(allocator),
        .WithData => |dataSolver| blk: {
            data = try readFile(dataSolver.data, allocator);
            break :blk try dataSolver.solve(allocator, data.?);
        },
    };

    const runDurations = try benchmark(solution, data, benchmarkIterations(solution), allocator);
    const min_time = common.min(i64, runDurations.items);
    const avg_time = common.avg(i64, runDurations.items);
    const max_time = common.max(i64, runDurations.items);
    const std_dev = common.stddev(i64, runDurations.items);

    runDurations.deinit();

    if (data) |d| {
        allocator.free(d);
    }

    return .{
        .answers = result,
        .min_time = min_time,
        .max_time = max_time,
        .avg_time = avg_time,
        .std_dev_time = std_dev,
    };
}

fn benchmark(action: Solution, data: ?[]const u8, iterations: u32, allocator: std.mem.Allocator) !std.ArrayList(i64) {
    var result = std.ArrayList(i64).init(allocator);

    var timer = try std.time.Timer.start();

    if (data) |d| {
        for (0..iterations) |_| {
            const start = timer.read();
            const answer = try action.WithData.solve(allocator, d);
            const end = timer.lap();
            try result.append(@intCast(@divTrunc(end - start, 1000)));
            answer.deinit(allocator);
        }
    } else {
        for (0..iterations) |_| {
            const start = timer.read();
            const answer = try action.Func.solve(allocator);
            const end = timer.lap();
            try result.append(@intCast(@divTrunc(end - start, 1000)));
            answer.deinit(allocator);
        }
    }

    return result;
}
