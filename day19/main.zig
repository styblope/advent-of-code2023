//! https://adventofcode.com/2023/day/19

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const splitSequence = std.mem.splitSequence;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const indexOfScalar = std.mem.indexOfScalar;
const splitScalar = std.mem.splitScalar;


const data = @embedFile("input");
// const data = @embedFile("test");

const MAX = 4000;
const P = [4]usize;
const Range = struct {lower: usize, upper: usize, split: usize=0, op: std.math.CompareOperator=.gt};
var map = std.StringHashMap([]const u8).init(std.heap.page_allocator);
var list = std.ArrayList([4]Range).init(std.heap.page_allocator);

var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    var sec = splitSequence(u8, data, "\n\n");
    // parse workflows
    var tokens = tokenizeAny(u8, sec.next().?, "{}\n");
    while (tokens.next()) |token| {
        try map.put(token, tokens.next().?);
    }

    // parse parts
    var lines = tokenizeScalar(u8, sec.next().?, '\n');
    while (lines.next()) |line| {
        var numerics = tokenizeAny(u8, line, "xmas{}=,");
        var part: P = undefined;
        for (0..4) |i| {
            part[i] = try parseInt(usize, numerics.next().?, 10);
        }
        // part 1
        if (try match("in", part)) sum1 += part[0] + part[1] + part[2] + part[3];
    }
    
    // part2
    try traverse("in", [_]Range{.{.lower=0, .upper=MAX}}**4);

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}

fn match(name: []const u8, part: P) !bool {
    if (name[0] == 'A') return true;
    if (name[0] == 'R') return false;

    var splits = splitScalar(u8, map.get(name).?, ',');
    while (splits.next()) |s| {
        if (indexOfScalar(u8, s, ':')) |ci| {
            const val = try parseInt(usize, s[2..ci], 10);
            const pi = indexOfScalar(u8, "xmas", s[0]).?;
            const op = switch (s[1]) {
                '>' => std.math.CompareOperator.gt,
                '<' => std.math.CompareOperator.lt,
                else => unreachable,
            };

            if (std.math.compare(part[pi], op, val))
                return match(s[ci+1..], part);
        }
        else return match(s, part);
    }
    return error.UnreachableRule;
}

fn traverse(name: []const u8, in: [4]Range) !void {
    if (name[0] == 'A') {
        try list.append(in);
        var prod: u64 = 1;
        for (0..4) |i| prod *= in[i].upper - in[i].lower; 
        sum2 += prod;
        return;
    }
    if (name[0] == 'R') return;

    var inner = in;
    var pi: ?usize = null; // part index
    var splits = splitScalar(u8, map.get(name).?, ',');
    while (splits.next()) |s| {
        // flip range
        if (pi) |i| {
            switch (inner[i].op) {
                .lt => inner[i].lower = inner[i].split,
                .gt => inner[i].upper = inner[i].split,
                else => undefined
            }
            pi = null;
        }
        var out = inner;
        var next = s; 
        if (indexOfScalar(u8, s, ':')) |ci| {
            next = s[ci+1..];
            const val = try parseInt(usize, s[2..ci], 10);
            pi = indexOfScalar(u8, "xmas", s[0]);
            const i = pi orelse unreachable;
            switch (s[1]) {
                '>' => {
                    inner[i].split = val;
                    inner[i].op = .gt;
                    out[i].lower = @max(inner[i].split, inner[i].lower);
                    out[i].upper = @max(inner[i].split, inner[i].upper);
                },
                '<' => {
                    inner[i].split = val-1;
                    inner[i].op = .lt;
                    out[i].upper = @min(inner[i].split, inner[i].upper);
                    out[i].lower = @min(inner[i].split, inner[i].lower);
                },
                else => unreachable,
            }
        }
        try traverse(next, out);
    }
}
