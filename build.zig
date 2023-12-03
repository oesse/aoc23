const std = @import("std");

pub fn build(b: *std.Build) !void {
    const test_step = b.step("test", "Run unit tests");

    try addExecutable(b, "day1_1", test_step);
    try addExecutable(b, "day1_2", test_step);
    try addExecutable(b, "day2_1", test_step);
    try addExecutable(b, "day2_2", test_step);
    try addExecutable(b, "day3_1", test_step);
    try addExecutable(b, "day3_2", test_step);
}

fn addExecutable(b: *std.Build, name: []const u8, test_step: *std.Build.Step) !void {
    var exe_name_buf: [128]u8 = undefined;
    var path_name_buf: [256]u8 = undefined;

    const exe_name = try std.fmt.bufPrintZ(&exe_name_buf, "aoc23_{s}", .{name});
    const path_name = try std.fmt.bufPrintZ(&path_name_buf, "src/{s}.zig", .{name});

    const exe = b.addExecutable(.{
        .name = exe_name,
        .root_source_file = .{ .path = path_name },
    });
    b.installArtifact(exe);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = path_name },
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    test_step.dependOn(&run_unit_tests.step);
}
