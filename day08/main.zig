//! https://adventofcode.com/2023/day/8

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
const tokenizeSequence = std.mem.tokenizeSequence;


const data = @embedFile("input");
// const data = @embedFile("test");
var nodes = std.AutoArrayHashMap(u64, struct {l:u64, r:u64}).init(std.heap.page_allocator);

var sum1: u64 = 0;

pub fn main() !void {
    var lines = tokenizeSequence(u8, data, "\n");
    const dirs = lines.next().?;
    const ZZZ = try parseInt(u64, "ZZZ", 36);
    const AAA = try parseInt(u64, "AAA", 36);
    var alist = std.ArrayList(u64).init(std.heap.page_allocator);

    while (lines.next()) |line| {
        const n = try parseInt(u64, line[0..3], 36);
        const l = try parseInt(u64, line[7..10], 36);
        const r = try parseInt(u64, line[12..15], 36);
        try nodes.put(n, .{.l=l, .r=r});
        
        if (line[2] == 'A') try alist.append(n);
    }

    // part 1
    var next: u64 = AAA;
    blk: while (true) {
        for (dirs) |d| {
            switch (d) {
                'L' => next = nodes.get(next).?.l,
                'R' => next = nodes.get(next).?.r,
                else => unreachable
            }
            sum1 += 1;
            if (next == ZZZ) break :blk;
        }
    }
    print("Part 1: {}\n", .{sum1});
    
    // part 2
    var periods = [_]u64{0}**8;
    for (0..alist.items.len) |i| {
        var count:u64 = 0;
        blk: while (true) {
            for (dirs) |d| {
                switch (d) {
                    'L' => alist.items[i] = nodes.get(alist.items[i]).?.l,
                    'R' => alist.items[i] = nodes.get(alist.items[i]).?.r,
                    else => unreachable
                }

                var buf:[256]u8 = undefined;
                const out = std.fmt.bufPrintIntToSlice(&buf, alist.items[i], 36, .upper, .{});
                count += 1;
                if (out[2] == 'Z') {
                    if (count != periods[i]) {
                        periods[i] = count;
                        count = 0;
                    } else {
                        // print("i{} i{} p{}\n", .{i, zinitial[i], zperiods[i]});
                        break :blk;
                    }
                }
            }
        }
    }
    
    // least common multiplier
    var lcm = std.mem.max(u64, &periods);
    for (periods[0..alist.items.len]) |p| {
        const gcd = std.math.gcd(lcm, p);
        lcm = lcm * p / gcd;
    }
    print ("Part 2: {}\n", .{lcm});
}
