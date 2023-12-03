const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
const Allocator = std.mem.Allocator;

const data = @embedFile("input");
// const data = @embedFile("test");

const Loc = struct {x:usize, y:usize,};

pub fn main() !void {
    var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer list.deinit();
    var gears = std.AutoHashMap(Loc, u64).init(std.heap.page_allocator);
    defer gears.deinit();

    var sum1 : u64 = 0;
    var sum2 : u64 = 0;

    var lines = std.mem.tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        try list.append(line);
    }
    
    var digits : [3]u8 = undefined;

    for (list.items, 0..) |row, y| {
        var dlen : usize = 0; // length of the digit (2 or 3)
        var nd = false; // continue to read next digit?
        var eol = false; // special case when a digit is found at the end of the line
        for (row, 0..) |char, x| {
            if (std.ascii.isDigit(char)) {
                digits[dlen] = char; 
                dlen += 1;
                nd = if (x < row.len-1) true else blk: { eol=true; break :blk false; };
            } else nd = false;

            // parse a number
            if (dlen > 0 and !nd) {
                const num = if (!eol) try std.fmt.parseInt(u64, row[x-dlen..x], 10)
                    else try std.fmt.parseInt(u64, row[x-dlen+1..], 10);

                // look for neighbour symbols
                var is_symbol = false;
                outer: for (0..3) |r| {
                    if (y == 0 and r == 0) continue;
                    if (y == list.items.len-1 and r == 2) continue;
                    for (0..dlen+2) |d| {
                        if (x == dlen and d == dlen+1) continue;
                        if (x == row.len-1 and d > dlen and eol) continue;
                        const yl = y+r-1;
                        const xl = x-d;
                        const c = list.items[yl][xl];
                        if (!std.ascii.isDigit(c) and c!='.') {
                            is_symbol = true;
                            
                            // part2, gear position
                            if (c == '*') {
                                if (try gears.fetchPut(.{.x=xl, .y=yl}, num)) |entry|
                                    sum2 += entry.value * num;
                            }
                            break :outer;
                        }
                    }
                }

                // print("{},{}\n", .{num, is_symbol});
                if (is_symbol) sum1 += num;
                dlen = 0;
            }
        }
    }

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}
