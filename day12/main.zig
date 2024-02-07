//! https://adventofcode.com/2023/day/12

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const HM = std.StringHashMap(usize);

const data = @embedFile("input");
// const data = @embedFile("test");
const N = 5; // number of folds
var sum: usize = 0;

pub fn main() !void {

    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var split = tokenizeScalar(u8, line, ' ');
        const left_orig = split.next() orelse unreachable;
        const left = std.mem.collapseRepeats(u8, @constCast(left_orig), '.');
        const right = split.next() orelse unreachable;

        // part 2 folding
        var l: usize = 0;
        var r: usize = 0;
        var lbuf: [256]u8 = undefined;
        var rbuf: [128]u8 = undefined;
        for (0..N) |_| {
            @memcpy(lbuf[l..l + left.len], left);
            lbuf[l + left.len] = '?';
            @memcpy(rbuf[r..r + right.len], right);
            rbuf[r + right.len] = ',';
            l += left.len + 1;
            r += right.len + 1;
        }
        const lf = lbuf[0..N * left.len + N - 1]; // left folded
        const rf = rbuf[0..N * right.len + N - 1]; // right folded

        var rc: [128]usize = undefined; // . and #
        rc[0] = 0; // first dot count
        var i: usize = 1;
        var rlen: usize = 0; // right-side sum of dots and hashes
        var iter = tokenizeScalar(u8, rf, ',');
        while (iter.next()) |num| : (i += 2) {
            rc[i] = try parseInt(u8, num, 10);
            rlen += rc[i];
            rc[i + 1] = 1;
            rlen += 1;
        }
        rc[i-1] = 0;
        rlen -= 1;

        var hm = std.StringHashMap(usize).init(arena.allocator());
        recurse(lf.len - rlen, 0, rc[0..i], lf, &hm);
        hm.deinit();
        _ = arena.reset(.retain_capacity);
    }
    print("Answer {}\n", .{sum});
}

/// fill: number of required dots to match the left-side length
/// index: index of current dot position (0, 2, 4, ... rc.len)
/// rc: right-side dot and hash counters
fn recurse(fill: usize, index: usize, rc: []usize, left: []const u8, hm: *HM) void {
    assert(@mod(index, 2) == 0);
    if (index < rc.len) {
        const prev = rc[index];

        var num: usize = 0;
        for (0..index) |idx| num += rc[idx]; // count # and . before index

        for (0..fill) |i| {
            if (failsAt(left, rc)) |f| if (f < num) continue;
            if (index + 2 <= rc.len) {
                const sum_before = sum;
                const buf = arena.allocator().alloc(u8, 200) catch unreachable;
                const key = std.fmt.bufPrint(buf, "{}{}{any}", .{fill-i, index+2, rc[index+2..]}) catch unreachable;
                // speed kick through memoization
                if (hm.get(key)) |val| {
                    sum += val;
                } else {
                    recurse(fill - i, index + 2, rc, left, hm);
                    hm.putNoClobber(key, sum - sum_before) catch unreachable;
                }
            }
            rc[index] += 1;
            num += 1;
        }
        if (failsAt(left, rc) == null)  sum += 1;
        rc[index] = prev;
    }
}

fn failsAt(left: []const u8, rc: []const usize) ?usize {
    var index: usize = 0;
    var count = rc[index];
    for (left, 0..) |l, j| {
        while (count == 0) {
            index += 1;
            if (index == rc.len) return null;
            count = rc[index];
        }
        const r: u8 = switch (index & 0x1) {
            0 => '.',
            1 => '#',
            else => unreachable,
        };
        count -= 1;
        if (l == '?') continue;
        if (l != r) return j;
    }
    return null;
}
