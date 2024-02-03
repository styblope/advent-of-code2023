//! https://adventofcode.com/2023/day/17

/// https://www.redblobgames.com/pathfinding/a-star/introduction.html
/// https://www.redblobgames.com/pathfinding/a-star/implementation.html#python-dijkstra

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;

const data = @embedFile("input");
// const data = @embedFile("test");
const w = 1 + (std.mem.indexOfScalar(u8, data, '\n') orelse unreachable);
const STEP_MAX = 10;
const STEP_MIN = 4; 

const Dir = enum {h, v, none};
const P = struct {pos: usize, dir: Dir};
const Q = struct {to: P, from: usize = 0, dist: usize = 0, priority: usize = 0};


pub fn main() !void {
    const sum = try dijkstra(0, data.len-2);
    print("Answer: {}\n", .{sum});
}

fn dijkstra(start: usize, finish: usize) !usize {
    var prev = std.AutoHashMap(P, P).init(std.heap.page_allocator);
    var queue = std.PriorityQueue(Q, void , cmp).init(std.heap.page_allocator, undefined);
    var distance = std.AutoHashMap(P, usize).init(std.heap.page_allocator);

    // try prev.put(.{.pos=start, .dir=.none}, .{.pos=start, .dir=.none});
    try distance.put(P{.pos=start, .dir=.none}, 0);
    try queue.add(Q{.to=P{.pos=start, .dir=.none}, .dist=data[start]-'0'});
    while (queue.len > 0) {
        const current = queue.remove();
        const neighbors = turns(current);

        for(neighbors) |v| {
            if (v.to.pos == 0 or v.to.dir == .none) continue;
            const tentative = distance.get(current.to).? + v.dist;
            if (prev.get(v.to) == null or tentative < distance.get(v.to) orelse std.math.maxInt(usize)) {
                try prev.put(v.to, current.to);
                try distance.put(v.to, tentative);

                var temp = v;
                temp.priority = tentative;
                try queue.add(temp);
            }
        }
    }
  
    var node = P{.pos=finish, .dir=.h};
    while (node.pos != start) {
        node = prev.get(P{.pos=node.pos, .dir=node.dir}).?;
    }
    return distance.get(P{.pos=finish, .dir=.h}).?;
}

fn cmp(context: void, a: Q, b: Q) std.math.Order {
    _ = context;
    return std.math.order(a.priority, b.priority);
}

fn turns(current: Q) [2*STEP_MAX]Q {
    var res = [_]Q{.{.to=P{.pos=0, .dir=.none}}}**(2*STEP_MAX);
    var cd = [_]usize{0, 0}; // cummulative distance in either direction

    for (1..STEP_MAX+1, 0..) |s, i|{ 
        var l = P{.pos=0, .dir=.none};
        var r = P{.pos=0, .dir=.none};

        // horizontal neighbors
        if (current.to.pos % w == current.from % w) {
            l.pos = current.to.pos -| s;
            if (l.pos < (current.to.pos/w)*w) l.pos = 0;

            r.pos = current.to.pos + s;
            if(r.pos > (current.to.pos/w)*w + w-2) r.pos = 0;

            l.dir = .h; r.dir = .h;
        }
        // vertical neighbors
        if (current.to.pos / w == current.from / w) {
            const v1 = current.to.pos -| w*s;
            if (v1 > 0) {
                r.pos = v1;
                r.dir = .v;
            }

            const v0 = current.to.pos + w*s;
            if (v0 < data.len-2) {
                l.pos = v0;
                l.dir = .v;
            }
        }

        cd[0] += data[l.pos] - '0';
        cd[1] += data[r.pos] - '0';

        res[i*2] = Q{.to=l, .from=current.to.pos, .dist=cd[0]};
        res[i*2+1] = Q{.to=r, .from=current.to.pos, .dist=cd[1]};
    }
    for (0..2*(STEP_MIN-1)) |i| res[i] = Q{.to=P{.pos=0, .dir=.none}, .from=0};
    return res;
}
