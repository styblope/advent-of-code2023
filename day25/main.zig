//! https://adventofcode.com/2023/day/25
// Export the graph as a Grahviz Dot file.
// Import and display the graph in a diagraming tool.
// https://www.yworks.com/yed-live/

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const indexOf = std.mem.indexOfScalar;


const data = @embedFile("input");
// const data = @embedFile("test");

pub fn main() !void {
    std.debug.print("digraph G {{\n", .{});

    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const colon = indexOf(u8, line, ':').?; 
        const parent = line[0..colon];

        var iter = tokenizeScalar(u8, line[colon+2..], ' ');
        while (iter.next()) |child| {
            print("{s} -> {s}\n", .{parent, child});
        }
    }
    std.debug.print("}}\n", .{});
}
