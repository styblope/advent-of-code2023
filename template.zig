//! https://adventofcode.com/2023/day/XXX

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        _ = line;
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

// Other possibly useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const splitAny = std.mem.splitAny;
const tokenizeSequence = std.mem.tokenizeSequence;
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

const parseFloat = std.fmt.parseFloat;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

fn chompInt(comptime T: type, line: []const u8, index: *usize) !T {
    var start: ?usize = null;
    var i: usize = index.*;
    while (i < line.len) : (i += 1) {
        if (std.ascii.isDigit(line[i])) {
            start = start orelse i;
            continue;
        } else if (start) |s| {
            print("{s}\n", .{line[s..i]});
            index.* = i;
            break;
        }
    }
    if (start) |s| return std.fmt.parseInt(T, line[s..i], 10) 
    else return error.ParseError;
}

test "chompInt" {
    const line = "xyz  123, K";
    const line2 = "xyz789";
    var i: usize = 2; try std.testing.expect(try chompInt(u64, line, &i) == 123); 
    try std.testing.expect(i == 8);
    i = 6; try std.testing.expect(try chompInt(u64, line, &i) == 23);
    i = 8; try std.testing.expectError(error.ParseError, chompInt(u64, line, &i));
    i = line.len - 1; try std.testing.expectError(error.ParseError, chompInt(u64, line, &i));
    i = 2; try std.testing.expect(try chompInt(u64, line2, &i) == 789);
}
