//! https://adventofcode.com/2023/day/XXX

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;


const data = @embedFile("input");
// const data = @embedFile("test");

var sum1 : u32 = 0;
var sum2 : u32 = 0;

pub fn main() !void {
    var sum : u32 = 0;

    // convert and sum 
    var lines = splitSequence(u8, data, "\n");
    while (lines.next()) |value| {
        sum += parseInt(i64, value, 10) catch 0; // empty string
    }
    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}


// Useful stdlib types 
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSequence = std.mem.tokenizeSequence;
const tokenizeScalar = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSequence = std.mem.splitSequence;
const splitScalar = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;
