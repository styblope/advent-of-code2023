//! https://adventofcode.com/2023/day/23

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;

const data = @embedFile("input");
// const data = @embedFile("test");
const W = std.mem.indexOfScalar(u8, data, '\n').? + 1;
const Visited = std.AutoHashMap(usize, void);

var sum1: usize = 0;
var sum2: usize = 0;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    defer arena.deinit();

    const start = std.mem.indexOfScalar(u8, data[0..W], '.').?;
    const finish = std.mem.lastIndexOfScalar(u8, data, '.').?;

    var visited = Visited.init(allocator);
    defer visited.deinit();
    try visited.put(start, {});
    try DFSWalk(start, start, finish, 0, &sum2, &visited);

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}

/// Brute-force depth-first traversal iteration
fn DFSWalk(start: usize, prev_vertex: usize, finish: usize, prev_steps: usize, sum: *usize, visited: *Visited) !void {
    var buf: [4]usize = undefined;
    var vclone = try visited.clone();
    defer vclone.deinit();

    var current = start;
    var previous = prev_vertex;
    var steps = prev_steps;

    while (current <= finish) {
        const neighbors = getNeighbors(current, previous, &buf);
        steps += 1;
        if (neighbors.len == 1) {
            previous = current;
            current = neighbors[0];
        } else {
            if (vclone.getKey(current) == null) {
                try vclone.put(current, {});
            } else return;

            for (neighbors) |next| {
                try DFSWalk(next, current, finish, steps, sum, &vclone);
            }
            return;
        }
        if (current == finish and steps > sum.*) sum.* = steps;
    }
}

fn getNeighbors(p: usize, prev: usize, buf: []usize) []usize {
    var temp: ?usize = undefined;
    var k: usize = 0;
    for (0..4) |i| {
        temp = switch (i) {
            0 => matchPos(p -| W),
            1 => matchPos(p + 1),
            2 => matchPos(p + W),
            3 => matchPos(p -| 1),
            else => unreachable,
        };
        if (temp) |t| {
            if (t == prev) continue;
            buf[k] = t;
            k += 1;
        }
    }
    return buf[0..k];
}

fn matchPos(p: usize) ?usize {
    if (p > data.len) return null;
    return if (data[p] != '#') p else null;
}
