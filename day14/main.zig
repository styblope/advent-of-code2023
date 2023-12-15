//! https://adventofcode.com/2023/day/14

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");
const W=100;
const H=100;


var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    var platform: [H][]u8 = undefined;
    init(&platform);
    
    roll(platform); 
    sum1 = load(platform);

    init(&platform);
    var last: u64 = 0;
    var lasti: u64 = 0;
    var i: usize = 0;
    var m: usize = 0;
    var p: usize = 0;
    while (i < 1000) : (i += 1) {
        for (0..4) |_| {
            roll(platform);
            rotateR(platform);
        }
        sum2 = load(platform);
        if (i > 900) {
            if (last == 0) {
                last = sum2;
                lasti = i;
            }
            else if (sum2 == last and p == 0) {
                p = i - lasti;
                m = @mod(1_000_000_000-i, p);
                std.debug.print("{} {} {}\n", .{sum2, p, m});
                last = 0;
                lasti = i;
            }
            else if (i == lasti+m-1) break;
        }
    }

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}

fn init(in: *[H][]u8) void {
    var lines = tokenizeScalar(u8, data, '\n');
    var l:usize = 0;
    while (lines.next()) |line| : (l += 1) {
       in.*[l] = @constCast(line);
    }
}

fn transpose (in: [H][]u8) void {
    for (0..H) |i| {
        for (i+1..W) |j| {
            const temp = in[i][j];
            in[i][j] = in[j][i];
            in[j][i] = temp;
        }
    }
}

fn rotateL(in: [H][]u8) void {
    transpose(in);
    for (0..W) |i| {
        var low: usize = 0;
        var high: usize = H-1;
        while (low < high) {
            const temp = in[low][i];
            in[low][i] = in[high][i];
            in[high][i] = temp;
            low += 1;
            high -= 1;
        }
    }
}

fn rotateR(in: [H][]u8) void {
    transpose(in);
    for (in) |row| {
        std.mem.reverse(u8, row);
    }
}

fn roll(in: [H][] u8) void {
    rotateR(in);
    for (in) |row| {
        var from: usize = 0;
        while(from < row.len) {
            const to = std.mem.indexOfPosLinear(u8, row, from, "#") orelse in.len;
            const ooo = std.mem.count(u8, row[from..to], "O");
            @memset(row[from..to-ooo], '.');
            @memset(row[to-ooo..to], 'O');
            from = to + 1;
        }
    }
    rotateL(in);
}

fn load(in: [H][]const u8) u64 {
    var val: u64 = 0;
    for(in, 0..) |row, i| {
        val += (in.len - i) * std.mem.count(u8, row, "O");
    }
    return val;
}
