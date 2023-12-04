//! https://adventofcode.com/2023/day/4

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

// const data = @embedFile("test");
// const W=5;
// const M=8;
// const C=6; // number of lines
const data = @embedFile("input");
const W=10;
const M=25;
const C=220; // number of lines
const Card = struct {wins: [W]u32, mine: [M]u32, copies: u32};
var cards : [C]Card = undefined;

var sum1 : u32 = 0;
var sum2 : u32 = 0;

pub fn main() !void {
    var lines = std.mem.tokenizeSequence(u8, data, "\n");
    var count : usize = 0;  
    while (lines.next()) |line| : (count += 1) {
        var iter = std.mem.splitSequence(u8, line[10..], " | ");
        // var iter = std.mem.splitSequence(u8, line[8..], " | "); // for test data
            
        const win_chars = iter.next() orelse return error.SplitError;
        var wins_raw = std.mem.tokenizeScalar(u8, win_chars, ' ');
        var i : usize = 0;
        while (wins_raw.next()) |r|: (i += 1) {
            cards[count].wins[i] = try std.fmt.parseInt(u32, r, 10);
        }

        const mine_chars = iter.next() orelse return error.SplitError;
        var mine_raw = std.mem.tokenizeScalar(u8, mine_chars, ' ');
        i = 0;
        while (mine_raw.next()) |r|: (i += 1) {
            cards[count].mine[i] = try std.fmt.parseInt(u32, r, 10);
        }

        // part 1
        var points: u32 = 0;
        var matches: u32 = 0;
        for (cards[count].wins) |w| {
            for (cards[count].mine) |m| {
                if (w == m) {
                    points = if (points == 0) 1 else points << 1;
                    matches += 1;
                    break;
                }
            }
        }
        sum1 += points;

        for (0..matches) |m| {
            cards[count + m + 1].copies += 1;
            cards[count + m + 1].copies += cards[count].copies;
        }
        sum2 += cards[count].copies;
    }
    sum2 += C;

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}
