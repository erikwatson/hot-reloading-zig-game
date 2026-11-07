
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.graph.host;
    const optimize = b.standardOptimizeOption(.{});

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/raylibwrapper.h"),
        .target = target,
        .optimize = optimize,
    });

    const imgui_translate = b.addTranslateC(.{
        .root_source_file = b.path("src/imgui_bridge.h"),
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "arena",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .imports = &.{
                .{
                    .name = "ray",
                    .module = translate_c.createModule(),
                },
                .{
                    .name = "imgui",
                    .module = imgui_translate.createModule(),
                },
                },
            }),
    });

    exe.root_module.addIncludePath(b.path("src"));
    exe.root_module.addIncludePath(b.path("vendor/rlImGui"));
    exe.root_module.addIncludePath(b.path("vendor/imgui"));

    exe.root_module.addCSourceFiles(.{
        .files = &.{
            "vendor/imgui/imgui.cpp",
            "vendor/imgui/imgui_draw.cpp",
            "vendor/imgui/imgui_widgets.cpp",
            "vendor/imgui/imgui_tables.cpp",
            "vendor/rlImGui/rlImGui.cpp",
            "src/imgui_bridge.cpp",
        },
        .flags = &.{"-std=c++17"},
    });

    exe.root_module.linkSystemLibrary("raylib", .{ .use_pkg_config = .yes });
    exe.root_module.linkSystemLibrary("stdc++", .{});

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run_cmd.step);
}

