const std = @import("std");
const ArrayList = std.ArrayList;

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;
    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    var sum: u32 = 0;

    while (true) {
        stdin.streamUntilDelimiter(line.writer(), '\n', null) catch break;

        const digits: u32 = try getDigits(line.items);
        // try stdout.print("replaced: {s} | digits: {d}\n", .{ line.items, digits });
        sum += digits;

        line.clearRetainingCapacity();
    }
    try stdout.print("The sum is: {?}\n", .{sum});
}

fn getDigits(line: []u8) !u32 {
    const digit_words: []const []const u8 = &.{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    var first: u8 = undefined;
    var last: u8 = undefined;

    const n = line.len;

    for (0..n) |i| {
        const c = line[i];
        if (std.ascii.isDigit(c)) {
            first = c;
            break;
        }
        if (matchesOneOf(line[i..], digit_words)) |match_idx| {
            first = std.fmt.digitToChar(@truncate(match_idx + 1), std.fmt.Case.lower);
            break;
        }
    }

    for (0..n) |i| {
        const j = n - i - 1;
        const c = line[j];
        if (std.ascii.isDigit(c)) {
            last = c;
            break;
        }
        if (matchesOneOf(line[j..], digit_words)) |match_idx| {
            last = std.fmt.digitToChar(@truncate(match_idx + 1), std.fmt.Case.lower);
            break;
        }
    }

    const s = [_]u8{ first, last };
    return try std.fmt.parseInt(u32, &s, 10);
}

fn matchesOneOf(str: []const u8, candidates: []const []const u8) ?usize {
    for (candidates, 0..) |candidate, i| {
        if (std.mem.startsWith(u8, str, candidate)) {
            return i;
        }
    }

    return null;
}
