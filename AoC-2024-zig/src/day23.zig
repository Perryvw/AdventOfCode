const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day23.txt",
    .solve = &solve,
    .benchmarkIterations = 1,
} };

const Node = []const u8;
const AdjacencyList = std.StringHashMap(std.ArrayList(Node));

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;

    var adjacencyList = AdjacencyList.init(allocator);
    defer {
        var iter = adjacencyList.valueIterator();
        while (iter.next()) |l| {
            l.deinit();
        }
        adjacencyList.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const left = line[0..2];
        const right = line[3..5];
        if (adjacencyList.getPtr(left)) |l| {
            try l.append(right);
        } else {
            var l = std.ArrayList(Node).init(allocator);
            try l.append(right);
            try adjacencyList.put(left, l);
        }

        if (adjacencyList.getPtr(right)) |l| {
            try l.append(left);
        } else {
            var l = std.ArrayList(Node).init(allocator);
            try l.append(left);
            try adjacencyList.put(right, l);
        }
    }

    // p1
    var cliques = std.AutoHashMap(u64, Clique).init(allocator);
    defer cliques.deinit();

    var mapiter = adjacencyList.keyIterator();
    while (mapiter.next()) |node| {
        try findCliques(node.*, &adjacencyList, &cliques);
    }

    var cliqueIter = cliques.valueIterator();
    while (cliqueIter.next()) |clique| {
        if (clique[0][0] == 't' or clique[1][0] == 't' or clique[2][0] == 't') {
            p1 += 1;
        }
    }
    const mc = try maxClique(allocator, &adjacencyList);
    defer mc.deinit();

    var outString = std.ArrayList(u8).init(allocator);
    for (mc.items) |node| {
        try outString.appendSlice(node);
        try outString.append(',');
    }
    try outString.resize(outString.items.len - 1);

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .str = try outString.toOwnedSlice() },
    };
}

fn compareStrings(_: void, lhs: []const u8, rhs: []const u8) bool {
    return std.mem.order(u8, lhs, rhs).compare(std.math.CompareOperator.lt);
}

const Clique = [3][]const u8;

fn findCliques(start: Node, adj: *const AdjacencyList, cliques: *std.AutoHashMap(u64, Clique)) !void {
    const connected = adj.get(start).?;
    for (connected.items) |other1| {
        for (connected.items) |other2| {
            if (!std.mem.eql(u8, other1, other2)) {
                const connected1 = adj.get(other1).?.items;
                const connected2 = adj.get(other2).?.items;
                if (contains(connected1, other2) and contains(connected2, other1)) {
                    var clique: Clique = .{ start, other1, other2 };
                    std.mem.sort([]const u8, &clique, {}, compareStrings);
                    try cliques.put(hash(clique), clique);
                }
            }
        }
    }
}

fn maxClique(allocator: std.mem.Allocator, adj: *AdjacencyList) !std.ArrayList(Node) {
    var r = std.StringHashMap(void).init(allocator);
    defer r.deinit();
    var p = std.StringHashMap(void).init(allocator);
    defer p.deinit();
    var x = std.StringHashMap(void).init(allocator);
    defer x.deinit();

    var nodes = adj.keyIterator();
    while (nodes.next()) |node| {
        try p.put(node.*, {});
    }

    var results = std.ArrayList(std.StringHashMap(void)).init(allocator);
    defer {
        for (results.items) |*i| {
            i.deinit();
        }
        results.deinit();
    }

    try bronKerybosh(allocator, &r, &p, &x, adj, &results);

    var max = results.items[0];
    for (results.items) |clique| {
        if (clique.count() > max.count()) {
            max = clique;
        }
    }

    var result = std.ArrayList(Node).init(allocator);
    var iter = max.keyIterator();
    while (iter.next()) |nodePtr| {
        try result.append(nodePtr.*);
    }

    std.mem.sort([]const u8, result.items, {}, compareStrings);

    return result;
}

fn bronKerybosh(allocator: std.mem.Allocator, r: *std.StringHashMap(void), p: *std.StringHashMap(void), x: *std.StringHashMap(void), adj: *AdjacencyList, results: *std.ArrayList(std.StringHashMap(void))) !void {
    if (p.count() == 0 and x.count() == 0) {
        // Report r as
        try results.append(try r.clone());
    }

    var nodes = try keysCopy(allocator, p);
    defer nodes.deinit();
    for (nodes.items) |node| {
        const neighbours = adj.get(node).?.items;

        // R U v
        var rNext = try r.clone();
        defer rNext.deinit();
        try rNext.put(node, {});
        // P intersect N(node)
        var pNext = try p.clone();
        defer pNext.deinit();
        try intersect(allocator, &pNext, neighbours);

        // X intersect N(node)
        var xNext = try x.clone();
        defer xNext.deinit();
        try intersect(allocator, &xNext, neighbours);

        // Recurse
        try bronKerybosh(allocator, &rNext, &pNext, &xNext, adj, results);

        // P = P \ node
        _ = p.remove(node);
        // X = X U node
        try x.put(node, {});
    }
}

fn intersect(allocator: std.mem.Allocator, set: *std.StringHashMap(void), adj: []const Node) !void {
    var keys = try keysCopy(allocator, set);
    defer keys.deinit();
    for (keys.items) |node| {
        if (!contains(adj, node)) {
            _ = set.remove(node);
        }
    }
}

fn keysCopy(allocator: std.mem.Allocator, map: *std.StringHashMap(void)) !std.ArrayList(Node) {
    var result = std.ArrayList(Node).init(allocator);
    var iter = map.keyIterator();
    while (iter.next()) |k| {
        try result.append(k.*);
    }
    return result;
}

fn hash(clique: Clique) u64 {
    return clique[0][0] + (@as(u64, @intCast(clique[0][1])) << 8) + (@as(u64, @intCast(clique[1][0])) << 16) + (@as(u64, @intCast(clique[1][1])) << 24) + (@as(u64, @intCast(clique[2][0])) << 32) + (@as(u64, @intCast(clique[2][1])) << 40);
}

fn contains(collection: []const Node, value: Node) bool {
    for (collection) |item| {
        if (std.mem.eql(u8, item, value)) return true;
    }
    return false;
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\kh-tc
        \\qp-kh
        \\de-cg
        \\ka-co
        \\yn-aq
        \\qp-ub
        \\cg-tb
        \\vc-aq
        \\tb-ka
        \\wh-tc
        \\yn-cg
        \\kh-ub
        \\ta-co
        \\de-co
        \\tc-td
        \\tb-wq
        \\wh-td
        \\ta-ka
        \\td-qp
        \\aq-cg
        \\wq-ub
        \\ub-vc
        \\de-ta
        \\wq-aq
        \\wq-vc
        \\wh-yn
        \\ka-de
        \\kh-ta
        \\co-tc
        \\wh-qp
        \\tb-vc
        \\td-yn
    );
    defer std.testing.allocator.free(result.p2.str);
    try std.testing.expectEqual(7, result.p1.i);
    try std.testing.expectEqualStrings("co,de,ka,ta", result.p2.str);
}
