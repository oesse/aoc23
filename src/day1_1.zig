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
        sum += digits;

        line.clearRetainingCapacity();
    }
    try stdout.print("The sum is: {?}\n", .{sum});
}

fn getDigits(line: []u8) !u32 {
    var first: u8 = undefined;
    var last: u8 = undefined;

    const n = line.len;

    for (0..n) |i| {
        const c = line[i];
        if (std.ascii.isDigit(c)) {
            first = c;
            break;
        }
    }

    for (0..n) |i| {
        const c = line[n - i - 1];
        if (std.ascii.isDigit(c)) {
            last = c;
            break;
        }
    }

    const s = [_]u8{ first, last };
    return try std.fmt.parseInt(u32, &s, 10);
}
