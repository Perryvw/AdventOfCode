const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day16.txt",
    .solve = &solve,
    .benchmarkIterations = 5,
} };

const State = struct {
    cost: u32,
    pos: common.Coord,
    direction: common.Direction,
    seen: SeenMap,
};
const SeenMap = std.AutoHashMap(common.Coord, bool);

fn solve(data: []const u8) !aoc.Answers {
    var p1: u64 = 1000000;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer std.debug.assert(gpa.deinit() != .leak);

    var arena = std.heap.ArenaAllocator.init(allocator);
    const arenaAllocator = arena.allocator();
    defer arena.deinit();

    const grid = common.ImmutableGrid.init(data);
    const startingPos = grid.find('S').?;

    const initialState = try arenaAllocator.create(State);
    initialState.* = .{
        .cost = 0,
        .pos = startingPos,
        .direction = common.Direction.Right,
        .seen = SeenMap.init(arenaAllocator),
    };
    try initialState.seen.put(startingPos, true);

    var minHeap = std.PriorityDequeue(*State, void, lessThan).init(allocator, {});
    defer minHeap.deinit();

    var seen = std.AutoHashMap(struct { pos: common.Coord, direction: common.Direction }, u32).init(allocator);
    defer seen.deinit();

    var cellsOnPath = SeenMap.init(allocator);
    defer cellsOnPath.deinit();

    try minHeap.add(initialState);

    while (minHeap.removeMinOrNull()) |state| {
        if (state.cost > p1) {
            continue;
        }

        if (seen.get(.{ .pos = state.pos, .direction = state.direction })) |cost| {
            if (state.cost > cost) {
                continue;
            }
        }
        try seen.put(.{ .pos = state.pos, .direction = state.direction }, state.cost);

        if (grid.isCharAtPosition(state.pos.x, state.pos.y, 'E')) {
            p1 = state.cost;
            var keys = state.seen.keyIterator();
            while (keys.next()) |p| {
                try cellsOnPath.put(p.*, true);
            }
            state.seen.deinit();
            continue;
        }

        // Either turn left
        const nextPosLeft = state.pos.add(state.direction.turnLeft().vector());
        if (!grid.isCharAtPosition(nextPosLeft.x, nextPosLeft.y, '#')) {
            if (!state.seen.contains(nextPosLeft)) {
                const nextLeft = try arenaAllocator.create(State);
                nextLeft.* = .{
                    .cost = state.cost + 1001,
                    .direction = state.direction.turnLeft(),
                    .pos = nextPosLeft,
                    .seen = try state.seen.clone(),
                };
                try nextLeft.seen.put(nextPosLeft, true);
                try minHeap.add(nextLeft);
            }
        }
        // Or turn right
        const nextPosRight = state.pos.add(state.direction.turnRight().vector());
        if (!grid.isCharAtPosition(nextPosRight.x, nextPosRight.y, '#')) {
            if (!state.seen.contains(nextPosRight)) {
                const nextRight = try arenaAllocator.create(State);
                nextRight.* = .{
                    .cost = state.cost + 1001,
                    .direction = state.direction.turnRight(),
                    .pos = nextPosRight,
                    .seen = try state.seen.clone(),
                };
                try nextRight.seen.put(nextPosRight, true);
                try minHeap.add(nextRight);
            }
        }
        // Or move forward
        const nextPos = state.pos.add(state.direction.vector());
        if (!grid.isCharAtPosition(nextPos.x, nextPos.y, '#') and !state.seen.contains(nextPos)) {
            state.cost += 1;
            state.pos = nextPos;
            try state.seen.put(state.pos, true);
            try minHeap.add(state);
        }
    }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = cellsOnPath.count() },
    };
}

fn lessThan(context: void, s1: *State, s2: *State) std.math.Order {
    _ = context;
    return std.math.order(s1.cost, s2.cost);
}

test "example" {
    const result = try solve(
        \\###############
        \\#.......#....E#
        \\#.#.###.#.###.#
        \\#.....#.#...#.#
        \\#.###.#####.#.#
        \\#.#.#.......#.#
        \\#.#.#####.###.#
        \\#...........#.#
        \\###.#.#####.#.#
        \\#...#.....#.#.#
        \\#.#.#.###.#.#.#
        \\#.....#...#.#.#
        \\#.###.#.#.#.#.#
        \\#S..#.....#...#
        \\###############
    );
    try std.testing.expectEqual(7036, result.p1.i);
    try std.testing.expectEqual(45, result.p2.i);
}

test "second example" {
    const result = try solve(
        \\#################
        \\#...#...#...#..E#
        \\#.#.#.#.#.#.#.#.#
        \\#.#.#.#...#...#.#
        \\#.#.#.#.###.#.#.#
        \\#...#.#.#.....#.#
        \\#.#.#.#.#.#####.#
        \\#.#...#.#.#.....#
        \\#.#.#####.#.###.#
        \\#.#.#.......#...#
        \\#.#.###.#####.###
        \\#.#.#...#.....#.#
        \\#.#.#.#####.###.#
        \\#.#.#.........#.#
        \\#.#.#.#########.#
        \\#S#.............#
        \\#################
    );
    try std.testing.expectEqual(11048, result.p1.i);
    try std.testing.expectEqual(64, result.p2.i);
}
