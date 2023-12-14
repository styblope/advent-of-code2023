//! https://adventofcode.com/2023/day/9

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;

const data = @embedFile("input");
// const data = @embedFile("test");

var sum1: i64 = 0;
var sum2: i64 = 0;

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        // var nums = [_]i64{0}**6; // test data
        var nums = [_]i64{0}**21;

        var nums_raw = tokenizeScalar(u8, line, ' ');
        var i:usize = 0;
        while (nums_raw.next()) |n| : (i += 1) {
            nums[i] = try parseInt(i64, n, 10);
        }
        
        var iter: usize = 0;
        while (true) {
            var zeros: i64 = 0;
            sum2 += if (@mod(iter, 2) == 0) nums[0] else -nums[0];
            for (1..nums.len-iter) |j| {
                nums[j-1] = nums[j] - nums[j-1];
                if (nums[j-1] == 0) zeros += 1;
            }
            sum1 += nums[nums.len - 1 - iter];
            if (zeros < (nums.len - iter - 1) ) iter += 1
            else break;
        }
    }

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}
