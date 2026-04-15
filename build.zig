const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const backend_module = b.createModule(.{
        .root_source_file = b.path("src/backend/root.zig"),
        .optimize = optimize,
        .target = target,
    });

    const frontend_module = b.createModule(.{
        .root_source_file = b.path("src/frontend/root.zig"),
        .optimize = optimize,
        .target = target,
    });

    const application = b.addExecutable(.{
        .name = "aimux",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .optimize = optimize,
            .target = target,
            .imports = &.{
                .{ .name = "frontend", .module = frontend_module },
                .{ .name = "backend", .module = backend_module },
            },
        }),
    });
    b.installArtifact(application);
}
