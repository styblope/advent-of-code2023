//! https://adventofcode.com/2023/day/24

const std = @import("std");
const print = std.debug.print;
const assert = std.debug.assert;
const tokenizeAny = std.mem.tokenizeAny;
const parseInt = std.fmt.parseInt;
const div = std.math.divExact;
const sub = std.math.sub;
const mul = std.math.mul;

const data = @embedFile("input");
// const data = @embedFile("test");
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

var sum1: u64 = 0;
var sum2: isize = 0;

pub fn main() !void {
    var list = std.ArrayList([6]isize).init(allocator);
    var tokens = tokenizeAny(u8, data, ", @\n");
    var i: usize = 0;
    var num: [6]isize = undefined;
    while (tokens.next()) |token| {
        num[i] = try parseInt(isize, token, 10);
        i += 1;
        if (i == 6) {
            try list.append(num);
            i = 0;
        }
    }

    for (0..list.items.len-1) |k| {
        for (k+1..list.items.len) |j| {
            // std.debug.print("{} {}\n", .{k, j});
            if (part1(list.items[k], list.items[j])) sum1 += 1;
        }
    }
    
    sum2 = try part2(&list);

    print("Part 1: {}\n", .{sum1});
    print("Part 2: {}\n", .{sum2});
}


fn part1(u: [6]isize, v: [6]isize) bool {
    var uf: [6]f32 = undefined;
    var vf: [6]f32 = undefined;
    for (0..6) |i| {
        uf[i] = @floatFromInt(u[i]);
        vf[i] = @floatFromInt(v[i]);
    }
     
    const a1 = uf[4] / uf[3];
    const b1 = uf[1] - a1 * uf[0];
    const a2 = vf[4] / vf[3];
    const b2 = vf[1] - a2 * vf[0];

    const x = (b2 - b1) / (a1 - a2);
    if (x*uf[3] < uf[0]*uf[3]) return false;
    if (x*vf[3] < vf[0]*vf[3]) return false;
    const y = a1 * x + b1; 

    return if (x >= 2e14 and x <= 4e14 and y >= 2e14 and y <= 4e14) true else false;
}

fn part2(list: *std.ArrayList([6]isize)) !isize {
    var hm = std.AutoHashMap([6]isize, usize).init(std.heap.page_allocator);
    const NUM = 10;

    for (0..NUM) |i| {
        const x1 = list.items[i][0];
        const y1 = list.items[i][1];
        const z1 = list.items[i][2];
        const vx1 = list.items[i][3];
        const vy1 = list.items[i][4];
        const vz1 = list.items[i][5];
        const x2 = list.items[i+1][0];
        const y2 = list.items[i+1][1];
        const z2 = list.items[i+1][2];
        const vx2 = list.items[i+1][3];
        const vy2 = list.items[i+1][4];
        const vz2 = list.items[i+1][5];

        var vx: isize = -1000;
        while (vx <= 1000) : (vx += 1) {
            var vy: isize = -1000;
            while (vy <= 1000) : (vy += 1) {
                const t2 = div(isize, ((y2 - y1)*(vx1 - vx) - (x2 - x1)*(vy1 - vy)), ((vx2 - vx)*(vy1 - vy) - (vy2 - vy)*(vx1 - vx))) catch continue;
                const t1 = div(isize, (x2 - x1) + (mul(isize, t2, vx2 - vx) catch continue), vx1 - vx) catch continue;
                const x = sub(isize, x1 + (mul(isize, vx1, t1) catch continue), mul(isize, vx, t1) catch continue) catch continue;
                const y = sub(isize, y1 + (mul(isize, vy1, t1) catch continue), mul(isize, vy, t1) catch continue) catch continue;
                if (t1 < 0 or t2 < 0) continue;

                const vz = div(isize, (z2 - z1) - t1*vz1 + (mul(isize, t2, vz2) catch continue), t2 - t1) catch continue; 
                const z = sub(isize, z1 + vz1*t1, vz*t1) catch continue;
                // std.debug.print("x={}, y={}, z={}, vx={}, vy={}, vz={}, t1={}, t2={}\n", .{x, y, z, vx, vy, vz, t1, t2});
                
                const buf = [_]isize{x, y, z, vx, vy, vz};
                if (hm.getEntry(buf)) |e| e.value_ptr.* += 1
                else try hm.put(buf, 1);
            }
        }
    }

    var iter = hm.iterator();
    while (iter.next()) |item| {
        if (item.value_ptr.* == NUM) return item.key_ptr[0] + item.key_ptr[1] + item.key_ptr[2];
    }
    return error.Oops;
}
