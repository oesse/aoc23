const std = @import("std");

pub fn build(b: *std.Build) !void {
    try addExecutable(b, "day1_1");
    try addExecutable(b, "day1_2");
    try addExecutable(b, "day2_1");
    try addExecutable(b, "day2_2");
    try addExecutable(b, "day3_1");
}

fn addExecutable(b: *std.Build, name: []const u8) !void {
    var exe_name_buf: [128]u8 = undefined;
    var path_name_buf: [256]u8 = undefined;

    const exe_name = try std.fmt.bufPrintZ(&exe_name_buf, "aoc23_{s}", .{name});
    const path_name = try std.fmt.bufPrintZ(&path_name_buf, "src/{s}.zig", .{name});

    const exe = b.addExecutable(.{
        .name = exe_name,
        .root_source_file = .{ .path = path_name },
    });
    b.installArtifact(exe);
}
