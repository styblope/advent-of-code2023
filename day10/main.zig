//! https://adventofcode.com/2023/day/10

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

var sum2: u64 = 0;
var sum1: u64 = 0;

const X = std.mem.indexOfScalar(u8, data, '\n') orelse unreachable;
const Y = X;
var array: [Y][]const u8 = undefined;
const Loc = struct {x: usize = 0, y: usize = 0};
const Dir = enum {e, s, w, n, none};
const LocDir = struct {l: Loc, d: Dir};
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
var path = std.ArrayList(LocDir).init(arena.allocator());

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');
    var y: usize = 0;
    var start: Loc = undefined;
    while (lines.next()) |line| : (y += 1) {
        array[y] = line;

        for (line, 0..) |l, x| {
            if (l == 'S') start = .{.x=x, .y=y};
        }
    } 
    
    for (0..3) |i| {
        sum1 = 0;
        const start_dir: Dir = @enumFromInt(i);
        path.clearAndFree();
        try path.append(.{.l=start, .d=start_dir});
        var n = next(start_dir, start) orelse continue;
        try path.append(n);
        while (true) {
            sum1 += 1;
            n = next(n.d, n.l) orelse break;
            try path.append(n);
            if (n.l.x == start.x and n.l.y == start.y) break;
        }
        if (sum1 > 0) break;
    }

    //part2
    for (array, 0..) |row, r| {
        var inside = false;
        var last: u8 = 0;
        for (row, 0..) |pipe, c| {
            if (isPath(.{.x=c, .y=r})) {
                if (pipe == '-') continue;
                if (pipe == 'J' and last == 'F') continue;
                if (pipe == '7' and last == 'L') continue;
                inside = !inside;
                last = pipe;
            } else if (inside) {
                sum2 += 1;
            }
        }
    }

    print("Part 1: {}\n", .{sum1/2 + 1});
    print("Part 2: {}\n", .{sum2});
}

fn isPath(a: Loc) bool {
    for (path.items) |i| {
        if (a.x == i.l.x and a.y == i.l.y) return true;
    }
    return false;
}

/// takes starting location and direction to go to
/// returns next location and next direction
fn next(dir_to: Dir, from: Loc) ?LocDir {
    const to = switch(dir_to) {
        .e => if (from.x < array[from.y].len) .{.x=from.x+1, .y=from.y} else null,
        .w => if (from.x > 0) .{.x=from.x-1, .y=from.y} else null,
        .n => if (from.y > 0) .{.x=from.x, .y=from.y-1} else null,
        .s => if (from.y < array.len) .{.x=from.x, .y=from.y+1} else null,
        .none => null,
    } orelse return null;

    const pipe: u8 = array[to.y][to.x];
    const set = switch(dir_to) {
        .e => "-J7",
        .w => "-LF",
        .n => "|F7",
        .s => "|JL",
        .none => unreachable,
    };
    if (std.mem.indexOfScalar(u8, set, pipe) == null) return null;
    return .{.l=to, .d=route(pipe, dir_to)};
}

fn route(pipe: u8, dir_from: Dir) Dir {
    return switch (pipe) {
        '|' => switch (dir_from) {
            .n => .n,
            .s => .s,
            else => unreachable,
        },
        '-' => switch (dir_from) {
            .e => .e,
            .w => .w,
            else => unreachable,
        },
        'L' => switch (dir_from) {
            .s => .e,
            .w => .n,
            else => unreachable,
        },
        'J' => switch (dir_from) {
            .s => .w,
            .e => .n,
            else => unreachable,
        },
        '7' => switch (dir_from) {
            .e => .s,
            .n => .w,
            else => unreachable,
        },
        'F' => switch (dir_from) {
            .w => .s,
            .n => .e,
            else => unreachable,
        },
        '.' => .none,
        else => unreachable,
    };
}
