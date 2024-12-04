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

pub fn parseInt(t: type, data: []const u8) t {
    var result: t = 0;
    for (data) |c| {
        result = 10 * result + (c - '0');
    }
    return result;
}