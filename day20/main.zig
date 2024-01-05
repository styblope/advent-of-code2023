//! https://adventofcode.com/2023/day/20

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeScalar = std.mem.tokenizeScalar;
const tokenizeSequence = std.mem.tokenizeSequence;
const parseInt = std.fmt.parseInt;
const expect = std.testing.expect;
const SH = std.StringHashMap;

const data = @embedFile("input");
// const data = @embedFile("test");

var result1: u64 = 0;
var result2: u64 = 1;

const Kind = enum { flipflop, conjunction, broadcaster, untyped };
const K = []const u8;
const Module = struct { kind: Kind, outputs: [8]?K };
const Pulse = enum(u1) { high, low };

const FlipFlop = struct {
    state: bool = false,

    pub fn run(self: *FlipFlop, in: Pulse) ?Pulse {
        if (in == .low) {
            self.state = !self.state;
            return if (self.state) .high else .low;
        } else return null;
    }
};

const Conjunction = struct {
    state: SH(bool),

    pub fn init() Conjunction {
        return Conjunction{ .state = SH(bool).init(std.heap.page_allocator) };
    }

    pub fn addInput(self: *Conjunction, input: []const u8) !void {
        try self.state.putNoClobber(input, false);
    }

    pub fn run(self: *Conjunction, in: Pulse, input: []const u8) !Pulse {
        switch (in) {
            .high => try self.state.put(input, true),
            .low => try self.state.put(input, false),
        }
        var bits: usize = 0;
        var si = self.state.valueIterator();
        while (si.next()) |s| {
            if (s.*) bits += 1;
        }
        return if (bits == self.state.count()) .low else .high;
    }
    pub fn highCount(self: *Conjunction) usize {
        var bits: usize = 0;
        var si = self.state.valueIterator();
        while (si.next()) |s| {
            if (s.*) bits += 1;
        }
        return bits;
    }
};

pub fn main() !void {
    var modules = SH(Module).init(std.heap.page_allocator);
    var flipflops = SH(FlipFlop).init(std.heap.page_allocator);
    var conjunctions = SH(Conjunction).init(std.heap.page_allocator);
    var to_rx: []const u8 = undefined;

    var lines = tokenizeScalar(u8, data, '\n');
    while (lines.next()) |line| {
        var iter = tokenizeSequence(u8, line, " -> ");

        var from = iter.next().?;
        const kind: Kind = if (std.mem.eql(u8, from, "broadcaster"))
            .broadcaster
        else switch (from[0]) {
            '%' => .flipflop,
            '&' => .conjunction,
            else => .untyped,
        };
        if (kind == .flipflop or kind == .conjunction) from = from[1..];

        switch (kind) {
            .flipflop => try flipflops.putNoClobber(from, FlipFlop{}),
            .conjunction => try conjunctions.putNoClobber(from, Conjunction.init()),
            else => {},
        }

        const to_list = iter.next().?;
        var to_iter = tokenizeSequence(u8, to_list, ", ");
        var outputs = [_]?K{null} ** 8;
        var i: usize = 0;
        while (to_iter.next()) |to| : (i += 1) {
            outputs[i] = to;
            if (std.mem.eql(u8, to, "rx")) to_rx = from;
        }
        try modules.put(from, Module{ .kind = kind, .outputs = outputs });
    }

    // find and add conjunction inputs
    var mi = modules.iterator();
    while (mi.next()) |module| {
        var i: usize = 0;
        while (module.value_ptr.outputs[i]) |output| : (i += 1) {
            const entry = try modules.getOrPutValue(output, Module{.kind = .untyped, .outputs = [_]?K{null}**8});
            var c = conjunctions.getPtr(entry.key_ptr.*) orelse continue;
            try c.addInput(module.key_ptr.*);
        }
    }

    // run the cycles
    const QueueItem = struct { to: K, pulse: Pulse, from: K };
    const List = std.DoublyLinkedList(QueueItem);
    var list = List{};

    var count_low: usize = 0;
    var count_high: usize = 0;
    var count: u64 = 1; // button presses
    var period_count = conjunctions.get(to_rx).?.state.count();

    cycle: while (count <= 10_000) : (count += 1) {
        count_low += 1; // button push = .low

        var first = List.Node{ .data = .{ .to = "broadcaster", .pulse = .low, .from = "button" } };
        list.append(&first);

        while (list.len > 0) {
            const ptr = list.popFirst() orelse break;
            const current = ptr.data;
            if (ptr != &first) std.heap.page_allocator.destroy(ptr);

            const module = modules.get(current.to).?;
            const out_pulse: ?Pulse = switch (module.kind) {
                .flipflop => blk: {
                    var f = flipflops.getPtr(current.to).?;
                    break :blk f.run(current.pulse);
                },
                .conjunction => blk: {
                    var c = conjunctions.getPtr(current.to).?;
                    break :blk try c.run(current.pulse, current.from);
                },
                .broadcaster => current.pulse,
                .untyped => null,
            };

            // distribute outgoing pulse to the module outputs/connected inputs
            if (out_pulse) |pulse| {
                var i: usize = 0;
                while (module.outputs[i]) |output| : (i += 1) {
                    switch (pulse) {
                        .low => count_low += 1,
                        .high => count_high += 1,
                    }

                    // part2, count periods (periods are primes, thus LCM is a simple product)
                    if (std.mem.eql(u8, current.to, to_rx) and current.pulse == .high and period_count > 0) {
                        result2 *= count;
                        period_count -= 1;
                        if (period_count == 0) break :cycle;
                    }

                    // std.debug.print("{s} -{s}-> {s}\n", .{ current.to, @tagName(pulse), output });

                    const node = try std.heap.page_allocator.create(List.Node);
                    node.* = List.Node{ .data = .{ .to = output, .pulse = pulse, .from = current.to } };
                    list.append(node);
                }
            }
            if (count == 1000) result1 = count_high * count_low;
        }
    }

    print("Part 1: {}\n", .{result1});
    print("Part 2: {}\n", .{result2});
}
