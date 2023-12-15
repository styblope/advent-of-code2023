//! https://adventofcode.com/2023/day/15

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;

const data = @embedFile("input");
// const data = @embedFile("test");

var sum1: u64 = 0;
var sum2: u64 = 0;

const LensHM = std.StringArrayHashMap(u8);
var boxhm = std.AutoHashMap(u64, LensHM).init(std.heap.page_allocator);

pub fn main() !void {
    var lines = tokenizeAny(u8, data, "\n,");
    while (lines.next()) |step| {
        sum1 += hash(step);

        if (step[step.len-1] == '-') {
            const label = step[0..step.len-1];
            if (boxhm.getPtr(hash(label))) |lenshm| {
                _ = lenshm.*.orderedRemove(label);
            }
        }
        else {
            const label = step[0..step.len-1];
            const focal = try parseInt(u8, step[step.len-1..step.len], 10);
            if (boxhm.getPtr(hash(label))) |lenshm| {
                try lenshm.*.put(label, focal);
            }
            else {
                var lenshm = LensHM.init(std.heap.page_allocator);
                try lenshm.put(label, focal);
                try boxhm.put(hash(label), lenshm);
            }
        }
    }

    var box_iter = boxhm.iterator();
    while (box_iter.next()) |box| {
        var i: usize = 0;
        var lens_iter = box.value_ptr.iterator();
        while (lens_iter.next()) |lens| : (i += 1) {
            sum2 += (box.key_ptr.* + 1) * (i + 1) * lens.value_ptr.*;
        }
    }

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}

fn hash(in: []const u8) u64 {
    var curr: u64 = 0;
    for (in) |c| {
        curr += c;
        curr *= 17;
        curr = @mod(curr, 256);
    }
    return curr;
}
