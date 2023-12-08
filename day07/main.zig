//! https://adventofcode.com/2023/day/7

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const parseInt = std.fmt.parseInt;

const data = @embedFile("input");
// const data = @embedFile("test");

var sum: u32 = 0;

const Hand = struct {h: []const u8, v: u32, t: HandType};
var hands = std.ArrayList(Hand).init(std.heap.page_allocator);
const HandType = enum(u8) { high, one, two, three, full, four, five };
// const cards = [_]u8{'2', '3', '4', '5', '6', '7', '8', '9', 'T', 'J', 'Q', 'K', 'A'}; // use this for part 1
const cards = [_]u8{'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A'}; // use this for part 2

pub fn main() !void {
    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        const h = line[0..5];
        const v = try parseInt(u32, line[6..], 10);
        try hands.append(.{.h=h, .v=v, .t=hand_type(h)});
    }

    std.mem.sort(Hand, hands.items, {}, sortFn);
    for (hands.items, 1..) |item, i| {
        // print("{} {s} {any} {}\n", .{i, item.h, item.t, item.v});
        // print("{s}\n", .{item.h});
        sum += @as(u32, @intCast(i))*item.v;
    }
    print("Answer: {}\n", .{sum});
}

fn hand_type(hand: []const u8) HandType {
    var counts=[_]u8{0}**cards.len; 
    var j: u8 = 0;
    for (cards, 0..) |c, i| {
        for (hand) |h| {
            if (c == h) {
                if (c == 'J') j += 1
                else counts[i] += 1;
            }
        }
    }
    
    // count pairs excluding J's
    var pairs: u8 = 0;
    for (counts) |c| {
        if (c == 2) pairs += 1;
    }
    var max = std.mem.max(u8, &counts);

    if (j > 0 ) {
        // print("{s} m{} j{} c{} -> ", .{hand, max, j, pairs});
        max = @min(j+max, 5);
        if (pairs > 0) pairs -= 1;
        // print("m{} j{} c{}\n", .{max, j, pairs});
    }
   
    switch(max) {
        5 => return HandType.five,
        4 => return HandType.four,
        3 => return if (pairs == 1) HandType.full else HandType.three,
        2 => return if (pairs == 2) HandType.two else HandType.one,
        1 => return HandType.high,
        else => unreachable,
    }
}

fn sortFn(_: void , a: Hand, b: Hand) bool {
    if (@intFromEnum(a.t) < @intFromEnum(b.t)) return true
    else if (a.t == b.t) {
        for (0..a.h.len) |i| {
            const la = lookup(a.h[i]);
            const lb = lookup(b.h[i]);
            if (la < lb) return true
            else if (la == lb) continue else return false;
        }
    }
    return false;
}

fn lookup(in: u8) usize {
    for (0..cards.len) |i| {
        if (in == cards[i]) return i;
    }
    unreachable;
}
