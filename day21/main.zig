//! https://adventofcode.com/2023/day/21

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const rotr = std.math.rotr;

const data = @embedFile("input");
// const data = @embedFile("test");
const W = std.mem.indexOfScalar(u8, data, '\n').? + 1;
const X = W - 1;
const Y = data.len / W;
const Loc = struct { x: isize, y: isize };

// const STEPS = 26501365;
const STEPS = 1000;

var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    const S = std.mem.indexOfScalar(u8, data, 'S').?;
    const sloc = pos2loc(S);
    _ = sloc;

    // part 1
    var ibuf: [20 * data.len]Loc = undefined;
    var obuf: [20 * data.len]Loc = undefined;
    var runtime_start: usize = 0;
    _ = &runtime_start;
    var in = ibuf[runtime_start..];
    var out = obuf[runtime_start..];

    ibuf[0] = pos2loc(S);
    in = ibuf[0..1];

    var ilast_even: usize = 0;
    var ilast_odd: usize = 0;
    for (1..STEPS + 1) |s| {
        // var i: usize = 0;
        const start = if (s % 2 == 0) ilast_even else ilast_odd;
        var i = if (s % 2 == 1) ilast_even else ilast_odd;
        if (s % 2 == 0) ilast_even = in.len else ilast_odd = in.len;

        for (in[start..]) |current| {

            outer: for (reachableLoc(current)) |next| {
                if (next) |n| {
                    // is one already present?
                    for (0..i) |j| {
                        // if (std.meta.eql(out[i - 1 - j], n)) continue :outer;
                        if (std.meta.eql(out[j], n)) continue :outer;
                    }

                    out[i] = n;
                    i += 1;
                }
            }
        }


        // swap slices
        const tmp = in;
        in.len = i;
        in = out[0..i];

        out = tmp;
        out.len = obuf.len;
        sum1 = i;

        if (s % 131 == 65 ) std.debug.print("{} {}\n", .{ s, sum1 });
    }

    print("Part 1: {}\n", .{sum1});

    // https://www.dcode.fr/lagrange-interpolating-polynomial
    print("Part 2: {}\n", .{sum2});
}

fn reachableLoc(loc: Loc) [4]?Loc {
    var res: [4]?Loc = undefined;
    res[0] = matchLoc(.{ .x = loc.x, .y = loc.y - 1 });
    res[1] = matchLoc(.{ .x = loc.x + 1, .y = loc.y });
    res[2] = matchLoc(.{ .x = loc.x, .y = loc.y + 1 });
    res[3] = matchLoc(.{ .x = loc.x - 1, .y = loc.y });
    return res;
}

fn matchLoc(loc: Loc) ?Loc {
    const ch = data[loc2pos(loc)];
    return if (ch == '.' or ch == 'S') loc else null;
}

fn pos2loc(pos: usize) Loc {
    assert(pos % W < W - 1);
    return Loc{ .x = @intCast(pos % W), .y = @intCast(pos / W) };
}

fn loc2pos(loc: Loc) usize {
    return @as(usize, @intCast(@mod(loc.y, Y))) * W + @as(usize, @intCast(@mod(loc.x, X)));
}
