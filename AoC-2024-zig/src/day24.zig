const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .WithData = .{
    .data = "data/day24.txt",
    .solve = &solve,
    .benchmarkIterations = 1,
} };

const Gate = union(enum) {
    And: struct { a: []const u8, b: []const u8 },
    Or: struct { a: []const u8, b: []const u8 },
    Xor: struct { a: []const u8, b: []const u8 },
};

fn solve(allocator: std.mem.Allocator, data: []const u8) !aoc.Answers {
    var p1: u64 = 0;
    const p2: u64 = 0;

    var values = std.StringHashMap(bool).init(allocator);
    defer values.deinit();

    const split = std.mem.indexOf(u8, data, "\n\n").?;

    var inputs = std.mem.tokenizeScalar(u8, data[0..split], '\n');
    while (inputs.next()) |input| {
        try values.put(input[0..3], input[5] == '1');
    }

    var connections = std.StringHashMap(Gate).init(allocator);
    defer connections.deinit();

    var connectionInp = std.mem.tokenizeScalar(u8, data[split + 2 ..], '\n');
    while (connectionInp.next()) |connectionStr| {
        if (connectionStr.len == 17) {
            try connections.put(connectionStr[14..], .{ .Or = .{ .a = connectionStr[0..3], .b = connectionStr[7..10] } });
        } else {
            if (connectionStr[4] == 'X') {
                try connections.put(connectionStr[15..], .{ .Xor = .{ .a = connectionStr[0..3], .b = connectionStr[8..11] } });
            } else {
                try connections.put(connectionStr[15..], .{ .And = .{ .a = connectionStr[0..3], .b = connectionStr[8..11] } });
            }
        }
    }

    var wires = connections.keyIterator();
    while (wires.next()) |wire| {
        if (wire.*[0] == 'z') {
            if (value(wire.*, &connections, &values)) {
                const num = @as(u64, 1) << @as(u6, @intCast(common.parseInt(u8, wire.*[1..3])));
                p1 += num;
            }
        }
    }

    // Fix input by swapping wires
    // try swapOutputs("ffj", "z08", &connections);
    // try swapOutputs("dwp", "kfm", &connections);
    // try swapOutputs("gjh", "z22", &connections);
    // try swapOutputs("jdr", "z31", &connections);
    //dwp,ffj,gjh,jdr,kfm,z08,z22,z31

    // Bit of code pointing out where the problem is
    // var iter = connections.iterator();
    // while (iter.next()) |kvp| {
    //     if (kvp.key_ptr.*[0] == 'z') {
    //         switch (kvp.value_ptr.*) {
    //             .Xor => {},
    //             else => {
    //                 std.debug.print("something fishy going on with {s}\n", .{kvp.key_ptr.*});
    //             },
    //         }
    //     }
    // }

    // for (0..63) |b| {
    //     // Add two 1-bit numbers to see if the gates responsible for that bit are wired correctly
    //     const inp = @as(u64, 1) << @intCast(b);
    //     const expected = inp << 1;
    //     const r = try add(allocator, inp, inp, &connections);
    //     if (r != expected) {
    //         std.debug.print("x{:0>2} {} + {} = {}\n", .{ b, inp, inp, r });
    //     }
    // }

    return .{
        .p1 = .{ .i = p1 },
        .p2 = .{ .i = p2 },
    };
}

fn swapOutputs(a: []const u8, b: []const u8, connections: *std.StringHashMap(Gate)) !void {
    const temp = connections.get(a).?;
    try connections.put(a, connections.get(b).?);
    try connections.put(b, temp);
}

fn add(allocator: std.mem.Allocator, a: u64, b: u64, connections: *const std.StringHashMap(Gate)) !u64 {
    var values = std.StringHashMap(bool).init(allocator);
    defer values.deinit();
    for (0..64) |bit| {
        const x = try std.fmt.allocPrint(allocator, "x{:0>2}", .{bit});
        const y = try std.fmt.allocPrint(allocator, "y{:0>2}", .{bit});
        try values.put(x, a & (@as(u64, 1) << @intCast(bit)) != 0);
        try values.put(y, b & (@as(u64, 1) << @intCast(bit)) != 0);
    }

    defer {
        var iter = values.keyIterator();
        while (iter.next()) |k| {
            allocator.free(k.*);
        }
    }

    var result: u64 = 0;
    var wires = connections.keyIterator();
    while (wires.next()) |wire| {
        if (wire.*[0] == 'z') {
            if (value(wire.*, connections, &values)) {
                const num = @as(u64, 1) << @as(u6, @intCast(common.parseInt(u8, wire.*[1..3])));
                result += num;
            }
        }
    }
    return result;
}

fn value(wire: []const u8, connections: *const std.StringHashMap(Gate), values: *const std.StringHashMap(bool)) bool {
    if (values.get(wire)) |v| {
        return v;
    } else {
        return switch (connections.get(wire).?) {
            .And => |gate| value(gate.a, connections, values) and value(gate.b, connections, values),
            .Or => |gate| value(gate.a, connections, values) or value(gate.b, connections, values),
            .Xor => |gate| xor(value(gate.a, connections, values), value(gate.b, connections, values)),
        };
    }
}

fn xor(a: bool, b: bool) bool {
    return (a and !b) or (b and !a);
}

test "example" {
    const result = try solve(std.testing.allocator,
        \\x00: 1
        \\x01: 1
        \\x02: 1
        \\y00: 0
        \\y01: 1
        \\y02: 0
        \\
        \\x00 AND y00 -> z00
        \\x01 XOR y01 -> z01
        \\x02 OR y02 -> z02
    );
    try std.testing.expectEqual(4, result.p1.i);
}

test "larger example" {
    const result = try solve(std.testing.allocator,
        \\x00: 1
        \\x01: 0
        \\x02: 1
        \\x03: 1
        \\x04: 0
        \\y00: 1
        \\y01: 1
        \\y02: 1
        \\y03: 1
        \\y04: 1
        \\
        \\ntg XOR fgs -> mjb
        \\y02 OR x01 -> tnw
        \\kwq OR kpj -> z05
        \\x00 OR x03 -> fst
        \\tgd XOR rvg -> z01
        \\vdt OR tnw -> bfw
        \\bfw AND frj -> z10
        \\ffh OR nrd -> bqk
        \\y00 AND y03 -> djm
        \\y03 OR y00 -> psh
        \\bqk OR frj -> z08
        \\tnw OR fst -> frj
        \\gnj AND tgd -> z11
        \\bfw XOR mjb -> z00
        \\x03 OR x00 -> vdt
        \\gnj AND wpb -> z02
        \\x04 AND y00 -> kjc
        \\djm OR pbm -> qhw
        \\nrd AND vdt -> hwm
        \\kjc AND fst -> rvg
        \\y04 OR y02 -> fgs
        \\y01 AND x02 -> pbm
        \\ntg OR kjc -> kwq
        \\psh XOR fgs -> tgd
        \\qhw XOR tgd -> z09
        \\pbm OR djm -> kpj
        \\x03 XOR y03 -> ffh
        \\x00 XOR y04 -> ntg
        \\bfw OR bqk -> z06
        \\nrd XOR fgs -> wpb
        \\frj XOR qhw -> z04
        \\bqk OR frj -> z07
        \\y03 OR x01 -> nrd
        \\hwm AND bqk -> z03
        \\tgd XOR rvg -> z12
        \\tnw OR pbm -> gnj
    );
    try std.testing.expectEqual(2024, result.p1.i);
}
