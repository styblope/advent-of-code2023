//! https://adventofcode.com/2023/day/6

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
const splitSequence = std.mem.splitSequence;
const tokenizeScalar = std.mem.tokenizeScalar;

const data = @embedFile("input");

var prod: u64 = 1;
var sum: u64 = 0;

pub fn main() !void {
    var lines = splitSequence(u8, data, "\n");

    // parse part1 - simple loop
    var time: [4]u64 = undefined;
    var dist: [4]u64 = undefined;
    var time_iter = tokenizeScalar(u8, lines.next().?[12..], ' ');
    var dist_iter = tokenizeScalar(u8, lines.next().?[12..], ' ');
    var i: usize = 0;
    while (time_iter.next()) |val| : (i += 1) time[i] = try parseInt(u64, val , 10);
    i = 0;
    while (dist_iter.next()) |val| : (i += 1) dist[i] = try parseInt(u64, val , 10);

    for (0..4) |race| {
        var ways: u64 = 0;
        for (0..time[race]) |h| {
            if ( (time[race]-h)*h > dist[race] ) ways += 1; 
        }
        prod *= ways;
    }

    // part2 - solve using quadratic formula!
    lines.reset();
    var buf: [16]u8 = undefined;
    const t = try parseInt(u64, merge(lines.next().?[12..], &buf), 10);
    const d = try parseInt(u64, merge(lines.next().?[12..], &buf), 10);
    
    const low = (t - std.math.sqrt(t*t - 4*d)) / 2;
    const high = (t + std.math.sqrt(t*t - 4*d)) / 2;
    sum = high - low;

    print("Part 1: {}\n", .{prod});
    print("Part 2: {}\n", .{sum});
}

fn merge(in: []const u8, buf: []u8) []const u8 {
    var i:usize = 0;
    for(in) |c| {
        if (std.ascii.isDigit(c)) {
            buf[i] = c;
            i += 1;
        }
    }
    return buf[0..i];
}
