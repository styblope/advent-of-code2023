//! https://adventofcode.com/2023/day/13

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeSequence = std.mem.tokenizeSequence;
const parseInt = std.fmt.parseInt;


const data = @embedFile("input");
// const data = @embedFile("test");

var sum1: u64 = 0;
var sum2: u64 = 0;

pub fn main() !void {
    var patterns = tokenizeSequence(u8, data, "\n\n");
    while (patterns.next()) |pattern| {
        // data mutation setup for part 2
        var pat: []u8 = @constCast(pattern);

        const cols = std.mem.indexOf(u8, pat, "\n") orelse unreachable;
        const rows = (pat.len + 1) / (cols + 1); 

        // part 1
        const val1 = find(pat, cols, rows, 0);
        sum1 += val1;

        // part 2
        var val2: usize = 0;
        for (0..pat.len) |p| {
            // flip
            if (pat[p] == '.') pat[p] = '#'
            else if (pat[p] == '#') pat[p] = '.'
            else continue; 

            val2 = find(pat, cols, rows, val1);
            if (val2 != val1 and val2 > 0) break;

            // flip back
            if (pat[p] == '.') pat[p] = '#'
            else if (pat[p] == '#') pat[p] = '.';
        }
        sum2 += val2;
    }
    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}


fn find(pat: []const u8, cols: usize, rows: usize, prev: usize) usize {
    var row: usize = 0;
    var hc: usize = 0; // horizontal match counter
    var hmatch: bool = false;

    var i: usize = 0;
    while (i < pat.len - (cols+1)) : (i += 1) {
        var val: usize = 0;

        // verical reflection line
        if (i < cols) {
            var vmatch: bool = false;
            blk: for (0..@min(i+1, cols-i-1)) |k| {
                for (0..rows) |r| {
                    const ci = r*(cols+1);
                    vmatch = pat[i+ci-k] == pat[i+1+ci+k];
                    if (!vmatch) break :blk;
                }
            } 
            if (vmatch) val = i + 1;
        }

        // horizontal reflection line
        if (i < pat.len - cols and pat[i] != '\n') {
            for (0..@min(row+1, rows-(row+1))) |k| {
                hmatch = pat[i - k*(cols+1)] == pat[i+cols+1 + k*(cols+1)];
                if (!hmatch) break;
            }
            if (hmatch) hc += 1;
            if (hc == cols) {
                val += (row + 1)*100;
            }
        }

        if (val != 0 and val != prev) return val;

        if (pat[i] == '\n') {
            row += 1;
            hc = 0;
        }
        
    }
    return 0;
}
