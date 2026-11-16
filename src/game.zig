const ray = @import("ray");
const std = @import("std");
const bezier = @import("./bezier.zig");
const types = @import("./types.zig");
const game_state = @import("./game_state.zig");

const LINE_SEGMENTS_PER_LINE = 32;

fn isMouseOverPoint(point: types.Point, mouse: ray.Vector2) bool {
    const dx = mouse.x - point.x;
    const dy = mouse.y - point.y;

    return dx * dx + dy * dy <= 15 * 15;
}

export fn game_init(state: *game_state.GameState) callconv(.c) void {
    // Initialise game state
    if (state.line_segments.len == 0) {
        state.line_segments = bezier.curveToLineSegments(
            state.persistent_arena.allocator(),
            state.curve,
            LINE_SEGMENTS_PER_LINE,
        ) catch unreachable;
    }
}

export fn game_update(state: *game_state.GameState, delta_time: f32) callconv(.c) void {
    _ = delta_time;
    // Update game logic
    const mouse = ray.GetMousePosition();

    const lineSegments = &state.line_segments;
    const curve = &state.curve;
    const persistent_arena = &state.persistent_arena;

    if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
        if (isMouseOverPoint(curve.start, mouse)) {
            curve.start.x = mouse.x;
            curve.start.y = mouse.y;

            lineSegments.* = bezier.curveToLineSegments(
                persistent_arena.allocator(),
                curve.*,
                LINE_SEGMENTS_PER_LINE,
            ) catch unreachable;
        }
    }
}

export fn game_draw(state: *game_state.GameState) callconv(.c) void {
    const lineSegments = &state.line_segments;
    const curve = &state.curve;

    for (lineSegments.*) |line| {
        ray.DrawLine(
            @intFromFloat(line.start.x),
            @intFromFloat(line.start.y),
            @intFromFloat(line.end.x),
            @intFromFloat(line.end.y),
            ray.BLUE,
        );
    }

    // draw the control points
    ray.DrawCircle(
        @intFromFloat(curve.start.x),
        @intFromFloat(curve.start.y),
        10,
        ray.RED,
    );

    ray.DrawCircle(
        @intFromFloat(curve.cp1.x),
        @intFromFloat(curve.cp1.y),
        10,
        ray.BLUE,
    );

    ray.DrawCircle(
        @intFromFloat(curve.cp2.x),
        @intFromFloat(curve.cp2.y),
        10,
        ray.BLUE,
    );

    ray.DrawCircle(
        @intFromFloat(curve.end.x),
        @intFromFloat(curve.end.y),
        10,
        ray.RED,
    );

    _ = state.frame_arena.reset(.retain_capacity);
}

export fn game_shutdown() void {
    // Clean up game state
}
