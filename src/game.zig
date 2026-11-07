const ray = @import("ray");
const std = @import("std");

export fn game_init() void {
    // Initialise game state
}

export fn game_update(delta_time: f32) void {
    _ = delta_time;
    // Update game logic
}

export fn game_draw() void {
    // Draw the game world
    ray.DrawText("Game version 1", 20, 20, 30, ray.BLUE);
}

export fn game_shutdown() void {
    // Clean up game state
}
