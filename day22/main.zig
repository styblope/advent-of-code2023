//! https://adventofcode.com/2023/day/22

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

const Brick = struct { x1: usize, y1: usize, z1: usize, x2: usize, y2: usize, z2: usize };

var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    var list = std.ArrayList(Brick).init(std.heap.page_allocator);

    var lines = tokenizeScalar(u8, data, '\n');
    var l: usize = 0;
    while (lines.next()) |line| : (l += 1) {
        var iter = tokenizeAny(u8, line, ",~");
        var v: [6]usize = undefined;
        var i: usize = 0;
        while (iter.next()) |token| : (i += 1) {
            v[i] = try parseInt(u9, token, 10);
        }
        try list.append(Brick{.x1=v[0], .y1=v[1], .z1=v[2], .x2=v[3], .y2=v[4], .z2=v[5]});
    }

    std.mem.sortUnstable(Brick, list.items, {}, comptime lessThanFn);

    _ = reduce(&list, null);

    for (0..list.items.len) |i| {
        var temp_list = try list.clone();
        const res = reduce(&temp_list, i);
        if (res == 0) sum1 += 1;
        sum2 += res;
    }

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}

fn reduce(list: *std.ArrayList(Brick), remove: ?usize) usize {
    var top = [_][10]usize{ [_]usize{0}**10 }**10;
    var fall_counter: usize = 0;
    for (list.items, 0..) |brick, i| {
        if (i == remove) continue;

        var drop: usize = std.math.maxInt(usize);
        for (brick.x1 ..brick.x2 + 1) |x| {
            for (brick.y1..brick.y2 + 1) |y| {
                drop = @min(drop, brick.z1 - top[x][y] - 1);
            }
        }

        if (remove != null and drop > 0) fall_counter += 1;

        list.items[i].z1 -= drop;
        list.items[i].z2 -= drop;

        for (brick.x1..brick.x2 + 1) |x| {
            for (brick.y1..brick.y2 + 1) |y| {
                top[x][y] = list.items[i].z2;
            }
        }
    }
    return fall_counter;
}

fn lessThanFn(_: void, a: Brick, b: Brick) bool {
    return a.z1 < b.z1;
}
