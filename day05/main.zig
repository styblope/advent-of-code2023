//! https://adventofcode.com/2023/day/5

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("input");
// const data = @embedFile("test");

var min1: ?u64 = null;
var min2: ?u64 = null;

const MAPS = 64;        // max number of map items
const CATEGORIES = 16;  // max number of maps
const SEEDS = 32;       // max number of seeds

pub fn main() !void {
    var lines = std.mem.tokenizeScalar(u8, data, '\n');

    // parse seeds
    var seeds: [SEEDS]u64 = undefined; // TODO dynamic list
    var seed_len: usize = 0;
    var iter = std.mem.tokenizeScalar(u8, lines.next().?[7..], ' ');
    while (iter.next()) |item|: (seed_len +=1) {
        seeds[seed_len] = try std.fmt.parseInt(u64, item, 10);
    }

    // parse maps
    var destination: [CATEGORIES][MAPS]u64= undefined;
    var source: [CATEGORIES][MAPS]u64 = undefined;
    var length: [CATEGORIES][MAPS]u64 = undefined;
    var cats: usize = 0;            // number of map categories
    var maps = [_]usize{0}**MAPS;   // number of maps per category

    var map: usize = 0;
    while (lines.next()) |line| : (map += 1) {
        if (std.ascii.isAlphabetic(line[0])) {
            cats += 1;
            map = 0;
            continue;
        }
        var map_iter = std.mem.tokenizeScalar(u8, line, ' ');
        destination[cats-1][map-1] = try std.fmt.parseInt(u64, map_iter.next().?, 10);
        source[cats-1][map-1] = try std.fmt.parseInt(u64, map_iter.next().?, 10);
        length[cats-1][map-1] = try std.fmt.parseInt(u64, map_iter.next().?, 10);
        maps[cats-1] = map;
    }
    
    // part 1
    for (seeds[0..seed_len]) |s| {
        var next: u64 = s; 
        for (0..cats) |c| {
            var m: usize = 0;
            while (m < maps[c]) : (m += 1) {
                if (next >= source[c][m] and next < source[c][m]+length[c][m]) {
                    next = destination[c][m] + (next-source[c][m]);
                    break;
                }
            }
        }
        min1 = @min(min1 orelse next, next);
    }

    // part 2
    var pair: usize = 0;
    while (pair < seed_len) : (pair += 2) { 
        const start = seeds[pair];
        var s: u64 = 0;
        while (s < seeds[pair+1]) : (s += 1) {
            var next: u64 = start + s; 
            var slack: ?u64 = null;
            for (0..cats) |c| {
                var m: usize = 0;
                while (m < maps[c]) : (m += 1) {
                    const end = source[c][m] + length[c][m];
                    if (next >= source[c][m] and next < end) {
                        const new_slack = end - next - 1; 
                        slack = @min(slack orelse new_slack, new_slack); 
                        next = destination[c][m] + (next-source[c][m]);
                        break;
                    }
                }
            }
            s += slack orelse 0;
            min2 = @min(min2 orelse next, next);
        } 
    }
    print("Part 1: {}\n", .{min1.?});
    print("Part 2: {}\n", .{min2.?});
}
