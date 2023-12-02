const std = @import("std");
const ArrayList = std.ArrayList;

const Sample = struct {
    red: u32,
    green: u32,
    blue: u32,

    fn init() Sample {
        return Sample{ .red = 0, .green = 0, .blue = 0 };
    }
};

const Game = struct {
    id: u32,
    samples: ArrayList(Sample),

    fn init(allocator: std.mem.Allocator) Game {
        var g = Game{ .id = 0, .samples = ArrayList(Sample).init(allocator) };
        return g;
    }
    fn deinit(self: Game) void {
        self.samples.deinit();
    }

    fn print(self: Game, writer: anytype) !void {
        try writer.print("Game (id: {d})\n", .{self.id});
        for (self.samples.items) |sample| {
            try writer.print("r: {d}, g: {d}, b: {d}\n", .{ sample.red, sample.green, sample.blue });
        }
    }

    fn maxCubes(self: Game) Sample {
        var result = Sample.init();
        for (self.samples.items) |sample| {
            result.red = @max(result.red, sample.red);
            result.green = @max(result.green, sample.green);
            result.blue = @max(result.blue, sample.blue);
        }

        return result;
    }
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    const allocator = std.heap.page_allocator;
    var line = ArrayList(u8).init(allocator);
    defer line.deinit();

    var sum: u32 = 0;
    const limit_cubes = Sample{ .red = 12, .green = 13, .blue = 14 };

    while (true) {
        stdin.streamUntilDelimiter(line.writer(), '\n', null) catch break;

        const game = try parseGame(line.items, allocator);
        defer game.deinit();
        // try game.print(stdout);

        if (isPossibleSample(game.maxCubes(), limit_cubes)) {
            sum += game.id;
        }

        line.clearRetainingCapacity();
    }
    try stdout.print("The sum is: {?}\n", .{sum});
}

fn parseGame(line: []const u8, allocator: std.mem.Allocator) !Game {
    var game = Game.init(allocator);
    errdefer game.deinit();

    const sample_spec = try splitGameId(line, &game.id);

    var it = std.mem.splitScalar(u8, sample_spec, ';');
    while (it.next()) |sample| {
        const s = try parseSample(sample);
        try game.samples.append(s);
    }

    return game;
}

fn splitGameId(line: []const u8, id: *u32) ![]const u8 {
    const game_label_name = "Game ";
    var it = std.mem.splitScalar(u8, line, ':');
    const label = it.next().?;

    id.* = try std.fmt.parseInt(u32, label[game_label_name.len..], 10);

    return it.rest();
}

fn parseSample(str: []const u8) !Sample {
    var sample = Sample.init();
    var it = std.mem.splitScalar(u8, str, ',');
    while (it.next()) |cube_spec| {
        try parseCubeSpec(cube_spec, &sample);
    }

    return sample;
}

fn parseCubeSpec(cube_spec: []const u8, sample: *Sample) !void {
    var it = std.mem.splitScalar(u8, std.mem.trim(u8, cube_spec, " "), ' ');
    const val = try std.fmt.parseInt(u32, it.next().?, 10);
    const cube_type = it.rest();
    if (std.mem.eql(u8, "red", cube_type)) {
        sample.red = val;
    } else if (std.mem.eql(u8, "green", cube_type)) {
        sample.green = val;
    } else if (std.mem.eql(u8, "blue", cube_type)) {
        sample.blue = val;
    }
}

fn isPossibleSample(sample: Sample, max: Sample) bool {
    return sample.red <= max.red and sample.green <= max.green and sample.blue <= max.blue;
}
