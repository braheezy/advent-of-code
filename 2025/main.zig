const std = @import("std");

const day1input = @embedFile("input/day1/input.txt");
const day2input = @embedFile("input/day2/input.txt");
const day3input = @embedFile("input/day3/input.txt");
const day4input = @embedFile("input/day4/input.txt");
const day5input = @embedFile("input/day5/input.txt");
const day6input = @embedFile("input/day6/input.txt");
const day7input = @embedFile("input/day7/input.txt");
const day8input = @embedFile("input/day8/input.txt");

pub fn main() void {}

test "day1" {
    var line_iter = std.mem.splitScalar(u8, day1input, '\n');

    var curr: usize = 50;
    var hit: usize = 0;
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        const move = line[0];
        var val = std.fmt.parseUnsigned(usize, line[1..], 10) catch unreachable;

        const over = @divTrunc(val, 100);
        // std.debug.print("over: {d}\n", .{over});
        hit += over;

        val %= 100;
        // if (val > 99) val %= 99;

        // std.debug.print("move: {c}, val: {d}, curr: {d}\n", .{ move, val, curr });

        if (move == 'R') {
            if (curr + val > 100) {
                std.debug.print("overage: curr: {d}, val: {d}\n", .{ curr, val });
                hit += 1;
            }
            curr += val;
        } else {
            while (val > curr) {
                if (curr != 0) {
                    hit += 1;
                    std.debug.print("underflow: curr: {d}, val: {d}\n", .{ curr, val });
                }
                curr += 99;
                val -= 1;
            }
            curr -= val;
        }
        curr = @mod(curr, 100);

        if (curr == 0) {
            std.debug.print("zero curr\n", .{});
            hit += 1;
        }
    }

    std.debug.print("Hit count: {d}\n", .{hit});
}

test "day2_part1" {
    var csv_iter = std.mem.splitScalar(u8, day2input, ',');
    var buf: [100]u8 = undefined;

    var sum: usize = 0;

    while (csv_iter.next()) |id_range| {
        var id_iter = std.mem.splitScalar(u8, id_range, '-');
        const first_id = std.fmt.parseUnsigned(usize, id_iter.first(), 10) catch unreachable;
        const rest = std.mem.trimEnd(u8, id_iter.rest(), " \n");
        const second_id = std.fmt.parseUnsigned(usize, rest, 10) catch unreachable;

        for (first_id..second_id + 1) |n| {
            const n_str = try std.fmt.bufPrint(&buf, "{}", .{n});
            if (n_str.len % 2 == 0) {
                const first_half = n_str[0 .. n_str.len / 2];
                const second_half = n_str[n_str.len / 2 ..];
                if (std.mem.eql(u8, first_half, second_half)) {
                    std.debug.print("wacky id: {s}\n", .{n_str});
                    sum += n;
                }
            }
        }
    }

    std.debug.print("Sum: {d}\n", .{sum});
}

test "day2_part2" {
    var csv_iter = std.mem.splitScalar(u8, day2input, ',');
    var buf: [100]u8 = undefined;

    var sum: usize = 0;

    while (csv_iter.next()) |id_range| {
        var id_iter = std.mem.splitScalar(u8, id_range, '-');
        const first_id = std.fmt.parseUnsigned(usize, id_iter.first(), 10) catch unreachable;
        const rest = std.mem.trimEnd(u8, id_iter.rest(), " \t\n");
        const second_id = std.fmt.parseUnsigned(usize, rest, 10) catch unreachable;

        for (first_id..second_id + 1) |n| {
            if (n < 10) continue; // single digit numbers can't work

            if (n < 100 and n % 11 == 0) {
                // two digit numbers that are the same digit
                // std.debug.print("2 wacky id: {d}\n", .{n});
                sum += n;
                continue;
            }
            const n_str = try std.fmt.bufPrint(&buf, "{}", .{n});

            const chu = if (n_str.len == 3) 2 else n_str.len / 2 + 1;
            for (1..chu) |chunk_size| blk: {
                // see if ever i-th chunk is the same
                const first_chunk = n_str[0..chunk_size];
                var j = chunk_size;
                while (j < n_str.len + 1) : (j += chunk_size) {
                    // n_str.len must be divisible by chunk size
                    if (n_str.len % chunk_size != 0) {
                        // std.debug.print("n_str.len must be divisible by chunk size\n", .{});
                        break :blk;
                    }
                    const current_chunk = n_str[j - chunk_size .. j];
                    // std.debug.print("j: {d}, n_str.len: {d}, first_chunk: {s}, chunk_size: {d}, current_chunk: {s}\n", .{ j, n_str.len, first_chunk, chunk_size, current_chunk });
                    if (!std.mem.eql(u8, first_chunk, current_chunk)) {
                        // std.debug.print("not wacky id: {s}\n", .{n_str});
                        break :blk;
                    }
                }
                std.debug.print("1 wacky id: {s}\n", .{n_str});
                sum += n;
                break;
            }
        }
    }

    std.debug.print("Sum: {d}\n", .{sum});
}

test "day3_part1" {
    var buf: [2]u8 = undefined;
    const digits = [9]u8{ '9', '8', '7', '6', '5', '4', '3', '2', '1' };
    var line_iter = std.mem.splitScalar(u8, day3input, '\n');
    var sum: usize = 0;

    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        // const max_digit, const second_max, const index, const second_index = maxDigit(line);
        // std.debug.print("max digit: {d}, second max digit: {d}, index: {d}, second index: {d}\n", .{ max_digit, second_max, index, second_index });
        var high_digit_loc: usize = 0;
        for (digits) |i| {
            high_digit_loc = std.mem.indexOfScalar(u8, line, i) orelse continue;
            if (high_digit_loc == line.len - 1) continue;
            break;
        }
        // std.debug.print("high digit loc: {d}, high_digit: {d}\n", .{ high_digit_loc, line[high_digit_loc] - '0' });

        var second_high_digit_loc: ?usize = null;
        var actual_index: usize = 0;
        for (digits) |i| {
            const hay = line[high_digit_loc + 1 ..];
            second_high_digit_loc = std.mem.indexOfScalar(u8, hay, i) orelse continue;
            actual_index = line.len - hay.len + second_high_digit_loc.?;
            // std.debug.print("hay: {s}, i: {d}, second_high_digit_loc: {d}\n", .{ hay, i - '0', actual_index });

            break;
        }
        // std.debug.print("secondhigh digit loc: {d}, second high_digit: {d}\n", .{ actual_index, line[actual_index] - '0' });

        const jolt = try std.fmt.bufPrint(
            &buf,
            "{d}{d}",
            .{
                line[high_digit_loc] - '0',
                line[actual_index] - '0',
            },
        );
        sum += std.fmt.parseUnsigned(usize, jolt, 10) catch unreachable;
    }
    std.debug.print("sum: {d}\n", .{sum});
}

test "day3_part2" {
    var line_iter = std.mem.splitScalar(u8, day3input, '\n');
    var sum: usize = 0;
    const input_length = 100;
    const exp_strike_count: u8 = input_length - 12;

    var stack = std.ArrayList(u8).empty;

    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        var current_strike_count = exp_strike_count;
        for (line) |x| {
            while (current_strike_count > 0 and stack.items.len > 0 and stack.items[stack.items.len - 1] < x) {
                _ = stack.pop();
                current_strike_count -= 1;
            }
            stack.append(allocator, x) catch unreachable;
        }
        while (current_strike_count > 0 and stack.items.len > 0) {
            _ = stack.pop();
            current_strike_count -= 1;
        }
        var buf: [100]u8 = undefined;
        const jolt = try std.fmt.bufPrint(
            &buf,
            "{s}",
            .{
                stack.items,
            },
        );
        std.debug.print("jolt: {s}\n", .{jolt});
        sum += std.fmt.parseUnsigned(usize, jolt, 10) catch unreachable;
        stack.clearRetainingCapacity();
    }

    std.debug.print("sum: {d}\n", .{sum});
}

const day4_input_size = 140;
test "day4_part1" {
    var line_iter = std.mem.splitScalar(u8, day4input, '\n');
    var grid: [day4_input_size][day4_input_size]u8 = undefined;
    var line_count: usize = 0;
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;

        for (line, 0..) |char, col| {
            grid[line_count][col] = char;
        }
        line_count += 1;
    }
    var total_freed: u16 = 0;
    while (removeFreeBlocks(&grid)) |free_count| {
        std.debug.print("free_count: {d}\n", .{free_count});
        total_freed += free_count;
    }

    std.debug.print("total_freed: {d}\n", .{total_freed});
}

// For each of the 8 areas surrounding the '@' symbol, return number of '.' blocks.
fn countStrikes(grid: [day4_input_size][day4_input_size]u8, y: usize, x: usize) usize {
    var strikes: u8 = 0;

    if (y == 0 or y == day4_input_size - 1) strikes += 3;
    if (x == 0 or x == day4_input_size - 1) strikes += 3;

    // top-left
    if (y > 0 and x > 0 and grid[y - 1][x - 1] == '.') strikes += 1;
    // top
    if (y > 0 and grid[y - 1][x] == '.') strikes += 1;
    // top-right
    if (y > 0 and x < day4_input_size - 1 and grid[y - 1][x + 1] == '.') strikes += 1;
    // left
    if (x > 0 and grid[y][x - 1] == '.') strikes += 1;
    // right
    if (x < day4_input_size - 1 and grid[y][x + 1] == '.') strikes += 1;
    // bottom-left
    if (y < day4_input_size - 1 and x > 0 and grid[y + 1][x - 1] == '.') strikes += 1;
    // bottom
    if (y < day4_input_size - 1 and grid[y + 1][x] == '.') strikes += 1;
    // bottom-right
    if (y < day4_input_size - 1 and x < day4_input_size - 1 and grid[y + 1][x + 1] == '.') strikes += 1;

    return strikes;
}

const allocator = std.heap.c_allocator;
fn removeFreeBlocks(grid: *[day4_input_size][day4_input_size]u8) ?u16 {
    var free_count: u16 = 0;
    const Pair = struct { x: usize, y: usize };
    var pairs = std.ArrayList(Pair).empty;
    defer pairs.deinit(allocator);

    for (grid, 0..) |row, i| {
        for (row, 0..) |col, j| {
            if (col == '@') {
                const num_strikes = countStrikes(grid.*, i, j);
                if (num_strikes >= 5) {
                    free_count += 1;
                    pairs.append(allocator, .{ .x = j, .y = i }) catch unreachable;
                }
            }
        }
    }

    // replace all pairs in grid with '.'
    for (pairs.items) |pair| {
        grid.*[pair.y][pair.x] = '.';
    }
    return if (free_count > 0) free_count else null;
}

const Range = struct {
    start: usize,
    end: usize,

    fn compare(_: void, a: Range, b: Range) bool {
        return a.start < b.start;
    }

    fn compareEnds(_: void, a: Range, b: Range) bool {
        return a.end < b.end;
    }
};

test "day5_part1" {
    var line_iter = std.mem.splitScalar(u8, day5input, '\n');
    var ranges = std.ArrayList(Range).empty;
    defer ranges.deinit(allocator);
    var fresh: usize = 0;
    while (line_iter.next()) |line| {
        if (line.len == 0) break;
        const hyphen_index = std.mem.indexOfScalar(u8, line, '-').?;
        const start = try std.fmt.parseInt(usize, line[0..hyphen_index], 10);
        const end = try std.fmt.parseInt(usize, line[hyphen_index + 1 ..], 10);
        const range = Range{ .start = start, .end = end };

        ranges.append(allocator, range) catch unreachable;
    }

    std.mem.sort(Range, ranges.items, {}, Range.compare);

    std.debug.print("sorted ranges:\n", .{});
    for (ranges.items) |range| {
        std.debug.print("Range: {d} - {d}\n", .{ range.start, range.end });
    }

    _ = handleOverlap(&ranges);
    while (collapseRanges(&ranges)) _ = handleOverlap(&ranges);

    std.debug.print("aligned ranges:\n", .{});
    for (ranges.items) |range| {
        std.debug.print("Range: {d} - {d}\n", .{ range.start, range.end });
    }

    var i: usize = 0;
    while (i < ranges.items.len) {
        fresh += ranges.items[i].end - ranges.items[i].start + 1;
        // } else {
        //     std.debug.print("ranges.items[i + 1].start: {d} - curr: {d}\n", .{ ranges.items[i].end, curr });
        //     fresh += ranges.items[i + 1].start - curr;
        //     ranges.items[i + 1].start = ranges.items[i].end;
        //     fresh += ranges.items[i].end - curr;
        // }
        i += 1;
    }

    std.debug.print("Fresh count: {d}\n", .{fresh});
}

fn collapseRanges(ranges: *std.ArrayList(Range)) bool {
    var i: usize = 0;
    var changed = false;
    while (i < ranges.items.len) {
        const range = ranges.items[i];
        // std.debug.print("Range: {d} - {d}\n", .{ range.start, range.end });

        if (i != 0) {
            // if this range fits cleanly in the previous range, skip it
            if (range.start >= ranges.items[i - 1].start and range.end <= ranges.items[i - 1].end) {
                std.debug.print("Skipping range {d} - {d} because it fits in {d} - {d}\n", .{ range.start, range.end, ranges.items[i - 1].start, ranges.items[i - 1].end });
                _ = ranges.swapRemove(i);
                changed = true;
            }
            // if two start ranges are the same, merge them
            // if (range.start == ranges.items[i - 1].start) {
            //     std.debug.print("Merging range {d} - {d} with {d} - {d}\n", .{ range.start, range.end, ranges.items[i - 1].start, ranges.items[i - 1].end });
            //     ranges.items[i - 1].end = @max(range.end, ranges.items[i - 1].end);
            //     _ = ranges.swapRemove(i);
            //     changed = true;
            // }
        }
        i += 1;
    }
    if (changed) {
        std.mem.sort(Range, ranges.items, {}, Range.compare);
    }
    return changed;
}

fn handleOverlap(ranges: *std.ArrayList(Range)) bool {
    var i: usize = 1;
    var changed = false;

    while (i < ranges.items.len) : (i += 1) {
        if (ranges.items[i - 1].end >= ranges.items[i].start) {
            changed = true;
            const tmp = ranges.items[i].end;
            ranges.items[i].end = ranges.items[i - 1].end;

            ranges.items[i - 1].end = tmp;
        }
    }
    return changed;
}

// tried:
// 4854487259084
// 4583546096879
// 4582107194840
// 4583860641327
test "day6_part1" {
    var line_iter = std.mem.splitScalar(u8, day6input, '\n');
    var grid = std.ArrayList([]usize).empty;
    defer grid.deinit(allocator);
    var i: usize = 0;
    const sum: usize = 0;
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        // std.debug.print("line len: {d}\n", .{line.len});

        var parts_iter = std.mem.splitScalar(u8, line, ' ');
        var j: usize = 0;
        var row_list = std.ArrayList(usize).empty;
        defer row_list.deinit(allocator);
        while (parts_iter.next()) |part| {
            if (part.len == 0) continue;

            const item = if (std.mem.eql(u8, part, "+") or std.mem.eql(u8, part, "*")) part[0] else blk: {
                break :blk try std.fmt.parseUnsigned(usize, part, 10);
            };
            try row_list.append(allocator, item);
            j += 1;
        }
        try grid.append(allocator, try row_list.toOwnedSlice(allocator));

        i += 1;
    }
    grid.items = try transpose(allocator, grid.items);
    std.debug.print("Grid: ({d}x{d})\n", .{ grid.items.len, grid.items[0].len });
    var row_index: usize = 0;
    for (grid.items) |row| {
        for (row, 0..) |cell, index| {
            if (index == grid.items.len - 1 and (cell == '+' or cell == '*')) {
                std.debug.print("{c} ", .{@as(u8, @intCast(cell))});
            } else {
                std.debug.print("{d} ", .{cell});
            }
        }
        row_index += 1;
        std.debug.print("\n", .{});
    }
    std.debug.print("rows: {d}\n", .{row_index});
    for (grid.items) |row| {
        // const operator = row[row.len - 1];
        // var curr_solution: usize = row[0];
        var digits_map = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
        defer digits_map.deinit();
        var j: usize = 0;
        while (j < row.len - 1) : (j += 1) {
            var cell = row[j];
            var digits = std.ArrayList(usize).empty;
            defer digits.deinit(allocator);
            while (cell > 0) {
                const digit = cell % 10;
                try digits.append(allocator, digit); // Add the digit to the list
                cell /= 10; // Remove the last digit
            }
            // std.mem.reverse(u8, digits.items);
            try digits_map.put(j, try digits.clone(allocator));
        }
        // std.debug.print("Solution: {d}\n", .{curr_solution});
        // sum += curr_solution;
        i = 0;
        while (i < j) : (i += 1) {
            std.debug.print("value: {any}\n", .{digits_map.get(i).?.items});
            // for (digits_map.get(i).?.items) |digit| {
            //     std.debug.print("digit: {d}\n", .{digit});
            // }
        }
        const trans = try transformDigitsMap(allocator, &digits_map, j);
        i = 0;
        std.debug.print("\ncolumns: {d}\n", .{j});
        while (i < j) : (i += 1) {
            std.debug.print("value: {any}\n", .{trans[i].items});
            // for (digits_map.get(i).?.items) |digit| {
            //     std.debug.print("digit: {d}\n", .{digit});
            // }
        }
    }

    std.debug.print("\nSum: {d}\n", .{sum});
}

fn transpose(al: std.mem.Allocator, src: [][]usize) ![][]usize {
    const rows = src.len;
    const cols = if (rows == 0) 0 else src[0].len;

    var dst = try al.alloc([]usize, cols);
    for (dst) |*col| {
        col.* = try al.alloc(usize, rows);
    }

    var i: usize = 0;
    while (i < rows) : (i += 1) {
        var j: usize = 0;
        while (j < cols) : (j += 1) {
            dst[j][i] = src[i][j];
        }
    }

    return dst;
}

fn firstOperatorIndex(line: *const []usize) usize {
    var i: usize = 0;
    while (i < line.len) : (i += 1) {
        if (line.*[i] == '+' or line.*[i] == '*') return i;
    }
    return line.len;
}

fn transformDigitsMap(
    al: std.mem.Allocator,
    digits_map: *const std.AutoHashMap(usize, std.ArrayList(usize)),
    row_count: usize,
    use_msd: bool, // false for '*', true for '+'
) ![]std.ArrayList(usize) {
    // find max row length
    var max_len: usize = 0;
    var it = digits_map.iterator();
    while (it.next()) |entry| {
        const l = entry.value_ptr.items.len;
        if (l > max_len) max_len = l;
    }

    // result[k] = k-th "place" group
    var out = try al.alloc(std.ArrayList(usize), max_len);
    for (out) |*row| {
        row.* = std.ArrayList(usize).empty;
    }

    // rows are keyed 0..row_count-1
    var r: usize = 0;
    while (r < row_count) : (r += 1) {
        const src_list = digits_map.get(r).?;
        const src = src_list.items;
        const L = src.len;

        var pos: usize = 0;
        while (pos < L) : (pos += 1) {
            if (use_msd) {
                // MSD-based: use reversed index within this row
                const idx = L - 1 - pos;
                try out[pos].append(al, src[idx]);
            } else {
                // LSD-based: index as-is
                try out[pos].append(al, src[pos]);
            }
        }
    }

    return out;
}
// tried:
// 1739 (too high)
// 1649
// 1010 (too low)
test "day7" {
    var line_iter = std.mem.splitScalar(u8, day7input, '\n');
    var laser_indexes = std.ArrayList(usize).empty;
    // var shadow_indexes = std.ArrayList(usize).empty;
    var splits: usize = 0;
    var found_carrot = false;

    // find S start index
    const first_line = line_iter.next().?;
    const start_index = std.mem.indexOfScalar(u8, first_line, 'S').?;
    try laser_indexes.append(allocator, start_index);
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        // std.debug.print("Line: {s}\n", .{line});
        for (line, 0..) |c, i| {
            if (c == '^' and std.mem.containsAtLeastScalar(usize, laser_indexes.items, 1, i)) {
                found_carrot = true;
                try laser_indexes.append(allocator, i - 1);
                if (i < line.len) {
                    try laser_indexes.append(allocator, i + 1);
                }
                while (std.mem.containsAtLeastScalar(usize, laser_indexes.items, 1, i)) {
                    const bi = std.mem.indexOfScalar(usize, laser_indexes.items, i).?;
                    _ = laser_indexes.swapRemove(bi);
                }
                // std.debug.print("laser_indexes: {any}\n", .{laser_indexes.items});
                splits += 1;
            }
        }
        // if (found_carrot) {
        //     found_carrot = false;
        //     shadow_indexes = try laser_indexes.clone(allocator);
        //     laser_indexes.clearRetainingCapacity();
        // }
    }
    std.debug.print("Splits: {}\n", .{splits});
}

const Point = struct {
    id: usize = 0,
    x: usize = 0,
    y: usize = 0,
    z: usize = 0,
};

test "day8" {
    var line_iter = std.mem.splitScalar(u8, day8input, '\n');

    var points = std.ArrayList(Point).empty;
    defer points.deinit(allocator);
    var i: usize = 0;
    while (line_iter.next()) |line| {
        if (line.len == 0) continue;
        var p = Point{};
        var csv_iter = std.mem.splitScalar(u8, line, ',');
        p.id = i;
        p.x = try std.fmt.parseUnsigned(usize, csv_iter.next().?, 10);
        p.y = try std.fmt.parseUnsigned(usize, csv_iter.next().?, 10);
        p.z = try std.fmt.parseUnsigned(usize, csv_iter.next().?, 10);
        try points.append(allocator, p);
        i += 1;
    }
    var distances = std.ArrayList(usize).empty;
    defer distances.deinit(allocator);
    i = 0;
    while (i < points.items.len) {
        var j: usize = i + 1;
        while (j < points.items.len) {
            try distances.append(distance(points.items[i], points.items[j]));
            j += 1;
        }
        i += 1;
    }
}

fn distance(p1: Point, p2: Point) usize {
    return std.math.sqrt(std.math.pow(p1.x - p2.x, 2) + std.math.pow(p1.y - p2.y, 2) + std.math.pow(p1.z - p2.z, 2));
}
