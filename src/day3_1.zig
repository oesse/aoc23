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

        line.clearRetainingCapacity();
    }
    try stdout.print("The sum is: {?}\n", .{sum});
}
