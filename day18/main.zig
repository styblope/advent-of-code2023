//! https://adventofcode.com/2023/day/18

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

const Pos = struct {x: isize, y: isize};
const Dir = enum {r, d, l, u, none};

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');

    var current = Pos{.x=0, .y=0};
    var boundary: usize = 0;
    var area: isize = 0;
    while (lines.next()) |line| {
        var iter = tokenizeScalar(u8, line, ' ');
        // part 1
        var dir = iter.next().?[0];
        var dist = try parseInt(isize, iter.next().?, 10);

        // part 2
        const temp = iter.next() orelse unreachable;
        dist = try parseInt(isize, temp[2..7], 16);
        dir = temp[7]; 

        boundary += @intCast(dist);
        const new = coord(dir, dist, current);
        area += shoelace(current, new);
        current = new;
    }
    assert(current.x==0 and current.y==0);

    // Pick's theorem: https://en.wikipedia.org/wiki/Pick%27s_theorem
    const inside = @as(usize, @intCast(area))/2 - boundary/2 + 1; 

    print("Anwer: {}\n", .{inside + boundary});
}

fn coord(dir: u8, dist: isize, in: Pos) Pos {
    var pos = in;
    switch (dir) {
        'R', '0' => pos.x += dist,
        'L', '2'  => pos.x -= dist,
        'U', '3' => pos.y -= dist,
        'D', '1' => pos.y += dist,
        else => unreachable,
    }
    return pos;
}

/// https://en.wikipedia.org/wiki/Shoelace_formula
fn shoelace(a: Pos, b: Pos) isize {
    return (a.x*b.y - b.x*a.y);
}
