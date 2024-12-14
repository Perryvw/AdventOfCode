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
    var isNegative = false;
    var result: t = 0;
    var start: usize = 0;

    if (isSignedInt(t) and data[0] == '-') {
        isNegative = true;
        start = 1;
    }

    for (data[start..]) |c| {
        result = 10 * result + (c - '0');
    }

    if (isSignedInt(t) and isNegative) {
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

pub const Grid = struct {
    data: []const u8,
    width: usize,
    height: usize,

    pub fn isInsideGrid(self: *const Grid, x: i32, y: i32) bool {
        return x >= 0 and x < self.width and y >= 0 and y < self.height;
    }

    pub fn isCharAtPosition(self: *const Grid, x: i32, y: i32, c: u8) bool {
        if (!self.isInsideGrid(x, y)) return false;
        return self.data[self.pos(x, y)] == c;
    }

    pub fn charAtPos(self: *const Grid, x: i32, y: i32) ?u8 {
        if (!self.isInsideGrid(x, y)) return null;

        return self.data[self.pos(x, y)];
    }

    pub fn pos(self: *const Grid, x: i32, y: i32) usize {
        std.debug.assert(x >= 0);
        std.debug.assert(x < self.width);
        std.debug.assert(y >= 0);
        std.debug.assert(y < self.height);
        // +1 to account for newlines
        return @intCast(@as(i32, @intCast(self.width + 1)) * y + x);
    }
};
