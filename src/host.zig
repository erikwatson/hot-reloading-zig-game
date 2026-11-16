const std = @import("std");
const ray = @import("ray");
const imgui = @import("imgui");
const build_options = @import("build_options");
const game_state = @import("./game_state.zig");

const GameInit = *const fn (*game_state.GameState) callconv(.c) void;
const GameUpdate = *const fn (*game_state.GameState, f32) callconv(.c) void;
const GameDraw = *const fn (*game_state.GameState) callconv(.c) void;
const GameShutdown = *const fn (*game_state.GameState) callconv(.c) void;

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

    fn unload(self: *Game, state: *game_state.GameState) void {
        self.shutdown(state);
        self.library.close();
    }
};

fn gameLibraryModified() c_long {
    return ray.GetFileModTime(@ptrCast(build_options.game_library_path.ptr));
}

pub fn main() void {
    ray.InitWindow(1280, 720, "Arena");
    defer ray.CloseWindow();

    imgui.imgui_init();
    defer imgui.imgui_shutdown();

    ray.SetTargetFPS(60);

    var state = game_state.GameState.init();
    defer state.deinit();

    var game = Game.load();
    game.init(&state);
    defer game.unload(&state);

    var editor_enabled = true;

    var last_modified = gameLibraryModified();
    var pending_reload = false;
    var pending_modified = last_modified;
    var reload_timer: f32 = 0;

    while (!ray.WindowShouldClose()) {
        const delta_time = ray.GetFrameTime();
        const modified = gameLibraryModified();

        // Detect a changed game library.
        if (modified != last_modified) {
            last_modified = modified;
            pending_modified = modified;
            pending_reload = true;
            reload_timer = 0;
        }

        // Wait until the file timestamp is stable for 300 ms.
        if (pending_reload) {
            if (modified != pending_modified) {
                pending_modified = modified;
                reload_timer = 0;
            } else {
                reload_timer += delta_time;
            }

            if (reload_timer >= 0.3) {
                game.unload(&state);
                game = Game.load();
                game.init(&state);

                pending_reload = false;
                std.debug.print("Game reloaded\n", .{});
            }
        }

        if (ray.IsKeyPressed(ray.KEY_E)) {
            editor_enabled = !editor_enabled;
        }

        game.update(&state, delta_time);

        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);

        game.draw(&state);

        if (editor_enabled) {
            imgui.imgui_begin();
            imgui.imgui_draw_debug();
            imgui.imgui_end();
        }

        ray.EndDrawing();
    }
}
