
const std = @import("std");
const ray = @import("ray");
const imgui = @import("imgui");
const build_options = @import("build_options");

const GameInit = *const fn () callconv(.c) void;
const GameUpdate = *const fn (f32) callconv(.c) void;
const GameDraw = *const fn () callconv(.c) void;
const GameShutdown = *const fn () callconv(.c) void;

const Game = struct {
    library: std.DynLib,
    init: GameInit,
    update: GameUpdate,
    draw: GameDraw,
    shutdown: GameShutdown,

    fn load() Game {
        var lib = std.DynLib.open(build_options.game_library_path) catch {
            @panic("Could not load game library");
        };

        return .{
            .library = lib,
            .init = lib.lookup(GameInit, "game_init") orelse @panic("Missing game_init"),
            .update = lib.lookup(GameUpdate, "game_update") orelse @panic("Missing game_update"),
            .draw = lib.lookup(GameDraw, "game_draw") orelse @panic("Missing game_draw"),
            .shutdown = lib.lookup(GameShutdown, "game_shutdown") orelse @panic("Missing game_shutdown"),
        };
    }

    fn unload(self: *Game) void {
        self.shutdown();
        self.library.close();
    }
};

pub fn main() void {
    ray.InitWindow(1280, 720, "Arena");
    defer ray.CloseWindow();

    imgui.imgui_init();
    defer imgui.imgui_shutdown();

    ray.SetTargetFPS(60);

    var game = Game.load();
    game.init();
    defer game.unload();

    var editor_enabled = true;

    while (!ray.WindowShouldClose()) {
        if (ray.IsKeyPressed(ray.KEY_E)) {
            editor_enabled = !editor_enabled;
        }

        if (ray.IsKeyPressed(ray.KEY_R)) {
            game.unload();
            game = Game.load();
            game.init();
        }

        game.update(ray.GetFrameTime());

        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);

        game.draw();

        if (editor_enabled) {
            imgui.imgui_begin();
            imgui.imgui_draw_debug();
            imgui.imgui_end();
        }

        ray.EndDrawing();
    }
}

