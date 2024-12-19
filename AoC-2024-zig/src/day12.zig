const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day12.txt",
    .solve = &solve,
} };

const Region = struct {
    val: u8,
    area: u32,
    perimeter: u32,
    sides: u32,
};
const Coord = struct { x: i32, y: i32 };

const RegionMap = std.AutoHashMap(Coord, *Region);

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    var p2: u64 = 0;

    const grid = common.ImmutableGrid.init(data);
    var regionMap = RegionMap.init(allocator);
    defer regionMap.deinit();

    var regions = std.ArrayList(Region).init(allocator);
    defer regions.deinit();

    for (0..grid.height) |y| {
        for (0..grid.width) |x| {
            const key: Coord = .{ .x = @intCast(x), .y = @intCast(y) };
            if (regionMap.contains(key)) continue;

            try regions.append(.{ .val = grid.charAtPos(key.x, key.y).?, .area = 0, .perimeter = 0, .sides = 0 });

            try growRegion(key.x, key.y, &grid, &regions.items[regions.items.len - 1], &regionMap);
        }
    }

    for (regions.items) |r| {
        p1 += cost(r);
        p2 += costDiscounted(r);
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn growRegion(x: i32, y: i32, grid: *const common.ImmutableGrid, region: *Region, map: *RegionMap) !void {
    const key: Coord = .{ .x = x, .y = y };
    if (map.contains(key)) return; // Already part of the region

    try map.put(key, region);

    const val = grid.charAtPos(x, y).?;

    const continuesRight = grid.isCharAtPosition(x + 1, y, val);
    const continuesLeft = grid.isCharAtPosition(x - 1, y, val);
    const continuesDown = grid.isCharAtPosition(x, y + 1, val);
    const continuesUp = grid.isCharAtPosition(x, y - 1, val);

    // Count fences by looking if region continues in any of the 4 directions
    // if it continues, recurse grow to there
    if (continuesRight) {
        try growRegion(x + 1, y, grid, region, map);
    } else {
        region.perimeter += 1;
    }
    if (continuesLeft) {
        try growRegion(x - 1, y, grid, region, map);
    } else {
        region.perimeter += 1;
    }
    if (continuesDown) {
        try growRegion(x, y + 1, grid, region, map);
    } else {
        region.perimeter += 1;
    }
    if (continuesUp) {
        try growRegion(x, y - 1, grid, region, map);
    } else {
        region.perimeter += 1;
    }

    // Count the nr of corners we encounter
    if (!continuesDown and !continuesLeft) {
        region.sides += 1;
    }
    if (!continuesDown and !continuesRight) {
        region.sides += 1;
    }
    if (!continuesUp and !continuesLeft) {
        region.sides += 1;
    }
    if (!continuesUp and !continuesRight) {
        region.sides += 1;
    }
    if (continuesUp and continuesRight and !grid.isCharAtPosition(x + 1, y - 1, val)) {
        region.sides += 1;
    }
    if (continuesUp and continuesLeft and !grid.isCharAtPosition(x - 1, y - 1, val)) {
        region.sides += 1;
    }
    if (continuesDown and continuesLeft and !grid.isCharAtPosition(x - 1, y + 1, val)) {
        region.sides += 1;
    }
    if (continuesDown and continuesRight and !grid.isCharAtPosition(x + 1, y + 1, val)) {
        region.sides += 1;
    }

    region.area += 1;
}

fn cost(region: Region) u64 {
    return region.area * region.perimeter;
}
fn costDiscounted(region: Region) u64 {
    return region.area * region.sides;
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\AAAA
        \\BBCD
        \\BBCC
        \\EEEC
    );
    try std.testing.expectEqual(140, result.p1.i);
    try std.testing.expectEqual(80, result.p2.i);
}

test "plots in plots" {
    const result = try solve(std.testing.allocator,
        \\OOOOO
        \\OXOXO
        \\OOOOO
        \\OXOXO
        \\OOOOO
    );
    try std.testing.expectEqual(772, result.p1.i);
    try std.testing.expectEqual(436, result.p2.i);
}

test "larger example" {
    const result = try solve(std.testing.allocator,
        \\RRRRIICCFF
        \\RRRRIICCCF
        \\VVRRRCCFFF
        \\VVRCCCJFFF
        \\VVVVCJJCFE
        \\VVIVCCJJEE
        \\VVIIICJJEE
        \\MIIIIIJJEE
        \\MIIISIJEEE
        \\MMMISSJEEE
    );
    try std.testing.expectEqual(1930, result.p1.i);
    try std.testing.expectEqual(1206, result.p2.i);
}

test "p2 extra example 1" {
    const result = try solve(std.testing.allocator,
        \\EEEEE
        \\EXXXX
        \\EEEEE
        \\EXXXX
        \\EEEEE
    );
    try std.testing.expectEqual(236, result.p2.i);
}

test "p2 extra example 2" {
    const result = try solve(std.testing.allocator,
        \\AAAAAA
        \\AAABBA
        \\AAABBA
        \\ABBAAA
        \\ABBAAA
        \\AAAAAA
    );
    try std.testing.expectEqual(368, result.p2.i);
}
