const std = @import("std");
const ArrayList = std.ArrayList;

const Table = struct {
    data: []u8,
    columns: usize,
    rows: usize,
    allocator: std.mem.Allocator,

    pub fn init(cols: usize, rows: usize, allocator: std.mem.Allocator) !Table {
        const n = cols * rows;
        return Table{ .data = try allocator.alloc(u8, n), .columns = cols, .rows = rows, .allocator = allocator };
    }
    pub fn deinit(self: *Table) void {
        self.allocator.free(self.data);
    }

    pub fn cell(self: *const Table, row: usize, col: usize) u8 {
        const i = row * self.columns + col;
        return self.data[i];
    }

    pub fn copyIntoRow(self: *Table, row: usize, src: []const u8) void {
        const startIdx = self.toIdx(row, 0);
        const endIdx = startIdx + self.columns;
        @memcpy(self.data[startIdx..endIdx], src);
    }

    pub fn rowSlice(self: *const Table, row: usize) []const u8 {
        const startIdx = self.toIdx(row, 0);
        const endIdx = startIdx + self.columns;
        return self.data[startIdx..endIdx];
    }

    fn toIdx(self: *const Table, row: usize, col: usize) usize {
        std.debug.assert(row < self.rows and col < self.columns);
        return row * self.columns + col;
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;

    var sum: u32 = 0;

    var table = try readTable(stdin, allocator);
    defer table.deinit();

    for (0..table.rows) |i| {
        for (0..table.columns) |j| {
            // First find symbols.
            const c = table.cell(i, j);
            if (std.ascii.isDigit(c) or c == '.') {
                continue;
            }

            // try stdout.print("Symbol '{c}' at: {d}, {d}\n", .{ c, i, j });
            for (i - 1..i + 2) |u| {
                if (u < 0 or u >= table.rows) {
                    continue;
                }

                const row = table.rowSlice(u);
                var dstart = @max(j - 1, 0);
                while (dstart <= j + 1) {
                    var dend: usize = undefined;
                    if (std.ascii.isDigit(row[dstart])) {
                        const digits = findDigits(row, dstart, &dstart, &dend);
                        try stdout.print("Number '{s}' at: {d}, {d}-{d}\n", .{ digits, u, dstart, dend });
                        const num = try std.fmt.parseInt(u32, row[dstart..dend], 10);
                        sum += num;
                        dstart = dend + 1;
                    } else {
                        dstart += 1;
                    }
                }
            }
        }
    }

    try stdout.print("The sum is: {?}\n", .{sum});
}

fn readTable(reader: anytype, allocator: std.mem.Allocator) !Table {
    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    var table: Table = undefined;
    var isInit = false;
    errdefer if (isInit) {
        table.deinit();
    };
    var row: usize = 0;

    while (true) {
        reader.streamUntilDelimiter(line.writer(), '\n', null) catch break;

        if (!isInit) {
            const n = line.items.len;
            table = try Table.init(n, n, allocator);
            isInit = true;
        }

        table.copyIntoRow(row, line.items);
        row += 1;
        line.clearRetainingCapacity();
    }

    return table;
}

fn findDigits(row: []const u8, pos: usize, start: *usize, end: *usize) []const u8 {
    std.debug.assert(std.ascii.isDigit(row[pos]));

    start.* = pos;
    end.* = pos;

    while (start.* > 0 and std.ascii.isDigit(row[(start.* - 1)])) {
        start.* -= 1;
    }

    while (end.* < row.len and std.ascii.isDigit(row[end.*])) {
        end.* += 1;
    }
    return row[start.*..end.*];
}

const testing = std.testing;
const eql = std.mem.eql;

test "expand digits" {
    const row: []const u8 = "467..";
    const j = 2;
    var start: usize = undefined;
    var end: usize = undefined;
    const digits: []const u8 = findDigits(row, j, &start, &end);

    try testing.expect(eql(u8, "467", digits));
    try testing.expect(0 == start);
    try testing.expect(3 == end);
}

test "expand digits 2" {
    const row: []const u8 = "..35..";
    const j = 2;
    var start: usize = undefined;
    var end: usize = undefined;
    const digits: []const u8 = findDigits(row, j, &start, &end);

    std.debug.print("\nstart {d} end {d} '{s}'\n", .{ start, end, digits });

    try testing.expect(eql(u8, "35", digits));
    try testing.expect(2 == start);
    try testing.expect(4 == end);
}
