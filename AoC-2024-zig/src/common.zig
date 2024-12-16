const std = @import("std");

// Split a string up in individual lines
pub const LinesIterator = struct {
    string: []const u8,
    index: usize = 0,
    pub fn next(self: *LinesIterator) ?[]const u8 {
        if (self.string[self.index..].len > 0) {
            const start = self.index;
            var seenReturn = false;
            var i: usize = start;
            for (self.string[self.index..]) |c| {
                if (c == '\r') {
                    seenReturn = true;
                } else if (c == '\n') {
                    const end = if (seenReturn) i - 1 else i;
                    self.index = i + 1;
                    return self.string[start..end];
                }
                i = i + 1;
            }
            const end = if (seenReturn) i - 1 else i;
            self.index = i;
            return self.string[start..end];
        } else {
            return null;
        }
    }
};

pub fn avg(t: type, data: []const t) t {
    const num = data.len;
    var result: i128 = 0;

    for (data) |d| {
        result += d;
    }
    return @intCast(@divTrunc(result, num));
}

pub fn min(t: type, data: []const t) t {
    var result: t = data[0];

    for (data) |d| {
        result = @min(result, d);
    }
    return result;
}

pub fn max(t: type, data: []const t) t {
    var result: t = data[0];

    for (data) |d| {
        result = @max(result, d);
    }
    return result;
}

pub fn stddev(t: type, data: []const t) f64 {
    const mean = avg(t, data);
    var value: t = 0;
    for (data) |d| {
        value += (d - mean) * (d - mean);
    }
    value = @divTrunc(value, @as(t, @intCast(data.len)));
    return std.math.sqrt(@as(f64, @floatFromInt(value)));
}

pub fn parseInt(t: type, data: []const u8) t {
    if (comptime isSignedInt(t)) {
        return parseSignedint(t, data);
    }

    var result: t = 0;
    for (data) |c| {
        result = 10 * result + (c - '0');
    }
    return result;
}

fn parseSignedint(t: type, data: []const u8) t {
    var isNegative = false;
    var result: t = 0;
    var start: usize = 0;

    if (data[0] == '-') {
        isNegative = true;
        start = 1;
    }

    for (data[start..]) |c| {
        result = 10 * result + (c - '0');
    }

    if (isNegative) {
        result *= -1;
    }

    return result;
}

fn isSignedInt(t: type) bool {
    switch (@typeInfo(t)) {
        .Int => |info| {
            return info.signedness == .signed;
        },
        else => return false,
    }
}

pub const Direction = enum {
    Up,
    Right,
    Down,
    Left,
    pub fn turnLeft(self: Direction) Direction {
        return switch (self) {
            .Up => .Left,
            .Right => .Up,
            .Down => .Right,
            .Left => .Down,
        };
    }
    pub fn turnRight(self: Direction) Direction {
        return switch (self) {
            .Up => .Right,
            .Right => .Down,
            .Down => .Left,
            .Left => .Up,
        };
    }
    pub fn vector(self: Direction) Coord {
        return switch (self) {
            .Up => .{ .x = 0, .y = -1 },
            .Down => .{ .x = 0, .y = 1 },
            .Left => .{ .x = -1, .y = 0 },
            .Right => .{ .x = 1, .y = 0 },
        };
    }
};
pub const Coord = struct {
    x: i32,
    y: i32,
    pub fn add(self: Coord, other: Coord) Coord {
        return .{
            .x = self.x + other.x,
            .y = self.y + other.y,
        };
    }
};

pub fn Grid(t: type) type {
    return struct {
        const Self = @This();

        data: t,
        width: usize,
        height: usize,
        allocator: ?std.mem.Allocator,

        pub fn deinit(self: Self) void {
            self.allocator.?.free(self.data);
        }

        pub fn isInsideGrid(self: Self, x: i32, y: i32) bool {
            return x >= 0 and x < self.width and y >= 0 and y < self.height;
        }

        pub fn isCharAtPosition(self: Self, x: i32, y: i32, c: u8) bool {
            if (!self.isInsideGrid(x, y)) return false;
            return self.data[self.pos(x, y)] == c;
        }

        pub fn charAtPos(self: Self, x: i32, y: i32) ?u8 {
            if (!self.isInsideGrid(x, y)) return null;

            return self.data[self.pos(x, y)];
        }

        pub fn pos(self: Self, x: i32, y: i32) usize {
            std.debug.assert(x >= 0);
            std.debug.assert(x < self.width);
            std.debug.assert(y >= 0);
            std.debug.assert(y < self.height);
            // +1 to account for newlines
            return @intCast(@as(i32, @intCast(self.width + 1)) * y + x);
        }

        pub fn find(self: Self, needle: u8) ?Coord {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    if (self.isCharAtPosition(@intCast(x), @intCast(y), needle)) {
                        return .{
                            .x = @intCast(x),
                            .y = @intCast(y),
                        };
                    }
                }
            }
            return null;
        }

        pub fn print(self: Self) void {
            for (0..self.height) |y| {
                for (0..self.width) |x| {
                    std.debug.print("{c}", .{self.charAtPos(@intCast(x), @intCast(y)).?});
                }
                std.debug.print("\n", .{});
            }
            std.debug.print("\n", .{});
        }

        pub fn init(data: t) Grid(t) {
            const width = std.mem.indexOf(u8, data, "\n").?;
            const height = @divExact(data.len + 1, width + 1);

            return .{
                .data = data,
                .width = width,
                .height = height,
                .allocator = null,
            };
        }

        pub fn initCopy(data: []const u8, allocator: std.mem.Allocator) !Grid([]u8) {
            const width = std.mem.indexOf(u8, data, "\n").?;
            const height = @divExact(data.len + 1, width + 1);

            const gridData = try allocator.alloc(u8, data.len);
            @memcpy(gridData, data);

            return .{
                .data = gridData,
                .width = width,
                .height = height,
                .allocator = allocator,
            };
        }
    };
}

pub const ImmutableGrid = Grid([]const u8);
pub const MutableGrid = Grid([]u8);
