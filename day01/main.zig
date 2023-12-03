//! https://adventofcode.com/2023/day/1

const std = @import("std");
const print = std.debug.print;

const data = @embedFile("input");

pub fn main() !void {
    var sum : u64 = 0;
    var lines = std.mem.splitScalar(u8, data, '\n');

    var digits : [16]u8 = undefined;
    while (lines.next()) |line| {
        if (line.len == 0 ) continue;
        var pos : usize = 0; // digit position
        for (line, 0..) |char, index| {
            digits[pos] = switch (char) {
                '0'...'9' => char - '0',
                else => spelledDigit(line, index) orelse continue, // for part 2 solution
                // else => {_ = index; continue;} // for part 1 solution
            };
            pos +=1;
        }
        sum += 10*digits[0] + digits[pos-1];
    }
    print("Answer: {}\n", .{sum});
}

// for part 2
fn spelledDigit(line: []const u8, index: usize) ?u8 {
    const digit_names = [_][]const u8{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine"};

    for (digit_names, 0..) |digit, i| {
        if (std.mem.startsWith(u8, line[index..], digit)) {
            return @intCast(i+1); 
        }
    }
    return null;
}
