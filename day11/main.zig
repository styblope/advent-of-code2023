//! https://adventofcode.com/2023/day/11

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

var sum: u64 = 0;

// const EXPANSION=2; // part 1
const EXPANSION=1_000_000; // part 2
const X = std.mem.indexOfScalar(u8, data, '\n') orelse unreachable;
const Y = X;
const Loc = struct {x: usize = 0, y: usize = 0};
var galaxies = std.ArrayList(Loc).init(std.heap.page_allocator);
var space: [Y][]const u8 = undefined;
var empty_cols = [_]bool{true}**X;

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');
    var y: usize = 0;
    var yexp: usize = 0;
    while (lines.next()) |line| : (y += 1) {
        space[y] = line;
        var empty = true;
        for (line, 0..) |char, x| {
            if (char == '#') {
                try galaxies.append(.{.x=x, .y=y+yexp});
                empty = false;
            }
        }
        if (empty) yexp += EXPANSION - 1;
    } 
    // count empty columns
    for (0..X) |c| {
        for (space) |rows| {
            if (rows[c] == '#') {
                empty_cols[c] = false;
                continue;
            }
        }
    }

    for(galaxies.items, 0..) |g, i| {
        for (0..g.x) |s| {
            if (empty_cols[s]) galaxies.items[i].x += EXPANSION - 1; 
        }
    }

    for (galaxies.items, 0..) |from, i| {
        for (galaxies.items[i+1..]) |to| {
            const lx = if (to.x > from.x) to.x - from.x else from.x - to.x; 
            const ly = if (to.y > from.y) to.y - from.y else from.y - to.y; 
            sum += lx+ly;
        }
    }
    print("Answer: {}\n", .{sum});
}
