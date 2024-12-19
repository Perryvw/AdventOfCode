const std = @import("std");
const aoc = @import("aoc.zig");
const common = @import("common.zig");

pub const solution = aoc.Solution{ .Func = .{
    .solve = &solve,
    .benchmarkIterations = 1,
} };

fn solve(allocator: std.mem.Allocator) !aoc.Answers {
    var registers = [3]u64{ 30878003, 0, 0 };
    const tape = [_]u8{ 2, 4, 1, 2, 7, 5, 0, 3, 4, 7, 1, 7, 5, 5, 3, 0 };
    const result = try runCode(allocator, &registers, &tape);
    defer result.deinit();

    const p1 = try allocator.alloc(u8, result.items.len * 2 - 1);

    for (0..result.items.len - 1) |i| {
        p1[i * 2] = result.items[i] + '0';
        p1[i * 2 + 1] = ',';
    }
    p1[p1.len - 1] = result.items[result.items.len - 1] + '0';

    // p2: 2,4,1,2,7,5,0,3,4,7,1,7,5,5,3,0
    //b = a >> 3;
    //b = b ^ 2 (b10); // take 2nd bit
    //c = a / 2**b;
    //a = a >> 3;
    //b = b ^ c;
    //b = b ^ 7 (b111); // take last 3 bits
    //output (b >> 3)
    //if (a != 0) goto start

    //input len 8 16, need 16 outs, so 16 a>> 3 where the last one leads to 0
    // so look in triplets of 3 bytes

    var i: usize = tape.len;
    var a: u64 = 0;
    while (i > 0) {
        i -= 1;
        findA: for (0..8) |j| {
            registers = .{ a + j, 0, 0 };
            const result2 = try runCode(allocator, &registers, &tape);
            defer result2.deinit();

            if (std.mem.eql(u8, tape[i..], result2.items)) {
                a += j;
                break :findA;
            }
        }
        a <<= 3;
    }
    // undo last shift
    a >>= 3;

    return .{
        .p1 = .{ .str = p1 },
        .p2 = .{ .i = a },
    };
}

const REGISTER_A = 0;
const REGISTER_B = 1;
const REGISTER_C = 2;

fn runCode(allocator: std.mem.Allocator, registers: []u64, instructions: []const u8) !std.ArrayList(u8) {
    var out = std.ArrayList(u8).init(allocator);

    var instruction_ptr: usize = 0;

    while (instruction_ptr < instructions.len) {
        const operator = instructions[instruction_ptr];
        const operand = instructions[instruction_ptr + 1];
        switch (operator) {
            0 => {
                // adv
                registers[REGISTER_A] = dv(registers, operand);
            },
            1 => {
                // bxl
                registers[REGISTER_B] ^= operand;
            },
            2 => {
                // bst
                registers[REGISTER_B] = @mod(combo(operand, registers), 8);
            },
            3 => {
                // jnz
                if (registers[REGISTER_A] != 0) {
                    instruction_ptr = operand;
                    continue; // skip increment
                }
            },
            4 => {
                // bxc
                registers[REGISTER_B] ^= registers[REGISTER_C];
            },
            5 => {
                // out
                const value = @mod(combo(operand, registers), 8);
                try out.append(@intCast(value));
            },
            6 => {
                // bdv
                registers[REGISTER_B] = dv(registers, operand);
            },
            7 => {
                // cdv
                registers[REGISTER_C] = dv(registers, operand);
            },
            else => @panic("unknown instruction!"),
        }
        instruction_ptr += 2;
    }

    return out;
}

fn combo(operand: u8, registers: []const u64) u64 {
    return switch (operand) {
        0 => 0,
        1 => 1,
        2 => 2,
        3 => 3,
        4 => registers[REGISTER_A],
        5 => registers[REGISTER_B],
        6 => registers[REGISTER_C],
        else => @panic("unkown combo operand"),
    };
}

fn dv(registers: []const u64, operand: u8) u64 {
    const numerator = registers[REGISTER_A];
    const denominator: u64 = @as(u64, 1) << @intCast(combo(operand, registers));
    return @divTrunc(numerator, denominator);
}

test "example" {
    var registers = [3]u64{ 729, 0, 0 };
    var tape = [_]u8{ 0, 1, 5, 4, 3, 0 };
    const result = try runCode(std.testing.allocator, &registers, &tape);
    defer result.deinit();

    try std.testing.expectEqualSlices(u8, &[_]u8{ 4, 6, 3, 5, 6, 3, 5, 2, 1, 0 }, result.items);
}

test "small example 1" {
    var registers = [3]u64{ 0, 0, 9 };
    var tape = [_]u8{ 2, 6 };
    const result = try runCode(std.testing.allocator, &registers, &tape);
    defer result.deinit();
    try std.testing.expectEqual(1, registers[REGISTER_B]);
}

test "small example 2" {
    var registers = [3]u64{ 10, 0, 0 };
    var tape = [_]u8{ 5, 0, 5, 1, 5, 4 };
    const result = try runCode(std.testing.allocator, &registers, &tape);
    defer result.deinit();

    try std.testing.expectEqualSlices(u8, &[_]u8{ 0, 1, 2 }, result.items);
}

test "small example 3" {
    var registers = [3]u64{ 2024, 0, 0 };
    var tape = [_]u8{ 0, 1, 5, 4, 3, 0 };
    const result = try runCode(std.testing.allocator, &registers, &tape);
    defer result.deinit();

    try std.testing.expectEqualSlices(u8, &[_]u8{ 4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0 }, result.items);
}

test "div" {
    const registers = [3]u64{ 16, 0, 0 };
    try std.testing.expectEqual(4, dv(&registers, 2));
}
