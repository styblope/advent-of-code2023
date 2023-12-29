//! https://adventofcode.com/2023/day/16

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("input");
// const data = @embedFile("test");

var sum1: u64 = 0;
var sum2: u64 = 0;

const Dir = enum {
    NORTH,
    SOUTH,
    EAST,
    WEST,
    NONE,
};

var splits = [_]u8{0}**data.len;
var p: usize = 0;

pub fn main() !void {
    const w = 1 + (std.mem.indexOfScalar(u8, data, '\n') orelse unreachable);
    
    var max: usize = 0;
    for (0..w-1) |pos| {
        splits = [_]u8{0}**data.len;
        // std.debug.print("{}\n", .{w*(w-2) + pos});
        // max = @max(max, traverse(pos, Dir.SOUTH));
        // max = @max(max, traverse(w*(w-2) + pos, Dir.NORTH));
        // max = @max(max, traverse(pos*w, Dir.EAST));
        max = @max(max, traverse(pos*w + (w-2), Dir.WEST));
    }
    sum2 = max;

    // sum2 = traverse(0, Dir.EAST);
    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});

}

fn traverse(pos: usize, dir: Dir) usize {
    var energized = std.bit_set.StaticBitSet(data.len).initEmpty(); // energized tiles
    const w = 1 + (std.mem.indexOfScalar(u8, data, '\n') orelse unreachable);

    var prev: usize = 0;
    var n = dir;
    p = pos;
    var p0 = p;
    blk: while(true) {
        while (true) {
            energized.set(p);
            // std.debug.print("{} {}\n", .{p, n});
            n = next(data[p], n);
            p = move(p, w, n);

            if (p == p0 or p >= data.len or @mod(p,w) == w-1 or n == .NONE) break; 
        }

        var c:usize = 0;
        for (splits, 0..) |split, i| {
            if (split == 1) {
                p = i; 
                n = .EAST; 
                p0 = p;
                continue :blk;
            }
            if (split == 3) {
                p = i; 
                n = .NORTH; 
                p0 = p;
                continue :blk;
            }
            c += split;
        }
        if (c != 0) break;
        p = p0;

        const ec = energized.count();
        if (prev == ec) return ec;
        prev = ec; 
    }
    return energized.count();
}

fn next(ch: u8, from: Dir) Dir {
    const ds = dirs(ch, from);
    if (ds[0] == opposite(from)) {
        return ds[1];
    } else {
        return ds[0];
    }
}

fn move(i: usize, w: usize, d: Dir) usize {
    return switch (d) {
        .NORTH => if (i > w) i - w else data.len,
        .SOUTH => i + w,
        .EAST => i + 1,
        .WEST => if (i > 0) i - 1 else data.len,
        .NONE => i,
    };
}

fn opposite(d: Dir) Dir {
    return switch (d) {
        .NORTH => .SOUTH,
        .SOUTH => .NORTH,
        .EAST => .WEST,
        .WEST => .EAST,
        else => unreachable,
    };
}

fn dirs(ch: u8, from: Dir) struct{ Dir, Dir } {
    return switch (ch) {
        '|' => if (from == .WEST or from == .EAST) splitV() else .{ .NORTH, .SOUTH },
        '-' => if (from == .NORTH or from == .SOUTH) splitH() else .{ .EAST, .WEST },
        '/' => if (from == .EAST or from == .SOUTH) .{ .WEST, .NORTH } else .{ .EAST, .SOUTH },
        '\\' => if (from == .EAST or from == .NORTH) .{ .WEST, .SOUTH } else .{ .EAST, .NORTH },
        else => .{ from, from },
    };
}

fn splitV() struct{ Dir, Dir } {
    if (splits[p] == 2) return .{ .NONE, .NONE };
    splits[p] = if (splits[p] == 0) 1 else 2; 
    return if (splits[p] == 1) .{ .NORTH, .NORTH } else .{ .SOUTH, .SOUTH };
}

fn splitH() struct{ Dir, Dir } {
    if (splits[p] == 4) return .{ .NONE, .NONE };
    splits[p] = if (splits[p] == 0) 3 else 4; 
    return if (splits[p] == 3) .{ .EAST, .EAST } else .{ .WEST, .WEST };
}
