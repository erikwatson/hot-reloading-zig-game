
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

    const options = b.addOptions();
    options.addOption(
        []const u8,
        "game_library_path",
        b.path("zig-out/lib/libarena_game.so").getPath(b),
    );

    // Host executable
    const exe = b.addExecutable(.{
        .name = "arena",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/host.zig"),
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
    exe.root_module.addOptions("build_options", options);

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

    // Game shared library
    const game = b.addLibrary(.{
        .name = "arena_game",
        .linkage = .dynamic,
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/game.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{
                    .name = "ray",
                    .module = translate_c.createModule(),
                }
            }
        }),
    });

    b.installArtifact(game);

    // Run host
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the game");
    run_step.dependOn(&run_cmd.step);
}

