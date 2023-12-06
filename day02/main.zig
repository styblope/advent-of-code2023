//! https://adventofcode.com/2023/day/2

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("input");

pub fn main() !void {
    var sum1 : u32 = 0;
    var sum2 : u32 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var iter = std.mem.splitSequence(u8, line, ": ");
        const game_raw = iter.next() orelse return error.ParsingFailure;
        const id = try std.fmt.parseInt(u32, game_raw[5..], 10);
        const buf = iter.next() orelse return error.ParsingFailure;

        var fewest_possible = @Vector(3, u32){0, 0, 0};
        var possible = true;
        // parse sets per game
        var sets = std.mem.splitSequence(u8, buf, "; ");
        while (sets.next()) |set| {
            // parse colors in sets
            var s = struct { red: u32 = 0, green: u32 = 0, blue: u32 = 0 }{};
            var colors = std.mem.splitSequence(u8, set, ", ");  
            while (colors.next()) |color| {
                // parse colors
                const index = std.mem.indexOfScalar(u8, color, ' ').?;
                const num : u8 = try std.fmt.parseInt(u8, color[0..index], 10); 
                switch(color[index+1]) {
                    'r' => s.red += num,
                    'g' => s.green += num,
                    'b' => s.blue += num,
                    else => unreachable
                }
            }

            // part 1
            if (s.red > 12 or s.green > 13 or s.blue > 14) possible = false;

            // part 2
            const s_vec = @Vector(3, u32){s.red, s.green, s.blue};
            fewest_possible = @max(s_vec, fewest_possible);
        }
        if (possible) sum1 += id;
        sum2 += @reduce(.Mul, fewest_possible);
    }
    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}
