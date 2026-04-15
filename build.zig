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

    const application_run_artifact = b.addRunArtifact(application);
    application_run_artifact.step.dependOn(b.getInstallStep());

    if (b.args) |arguments| {
        application_run_artifact.addArgs(arguments);
    }

    const application_run_step = b.step("run", "Run the application");
    application_run_step.dependOn(&application_run_artifact.step);

    const application_test = b.addTest(.{
        .name = "aimux-test",
        .root_module = application.root_module,
    });

    const application_test_artifact = b.addRunArtifact(application_test);
    application_test_artifact.step.dependOn(b.getInstallStep());

    const application_test_step = b.step("test", "Test the app");
    application_test_step.dependOn(&application_test_artifact.step);

    const application_check = b.addExecutable(.{
        .name = "aimux-check",
        .root_module = application.root_module,
    });

    const application_check_step = b.step("check", "Check the app");
    application_check_step.dependOn(&application_check.step);
}
