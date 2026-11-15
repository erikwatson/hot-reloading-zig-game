const ray = @import("ray");
const std = @import("std");
const bezier = @import("./bezier.zig");
const types = @import("./types.zig");

var curve = types.Curve{
    .start = types.Point{
        .x = 100,
        .y = 100,
    },
    .cp1 = types.Point{
        .x = 130,
        .y = 75,
    },
    .cp2 = types.Point{
        .x = 750,
        .y = 325,
    },
    .end = types.Point{
        .x = 1000,
        .y = 100,
    },
};

var persistent_arena: std.heap.ArenaAllocator = undefined;
var persistent_allocator: std.mem.Allocator = undefined;

var frame_arena: std.heap.ArenaAllocator = undefined;
var frame_allocator: std.mem.Allocator = undefined;

const LINE_SEGMENTS_PER_LINE = 32;
var lineSegments: []types.Line = &.{};

fn isMouseOverPoint(point: types.Point, mouse: ray.Vector2) bool {
    const dx = mouse.x - point.x;
    const dy = mouse.y - point.y;

    return dx * dx + dy * dy <= 15 * 15;
}

export fn game_init() void {
    // Initialise game state
    frame_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    frame_allocator = frame_arena.allocator();

    persistent_arena = std.heap.ArenaAllocator.init(
        std.heap.page_allocator,
    );
    persistent_allocator = persistent_arena.allocator();

    lineSegments = bezier.curveToLineSegments(
        persistent_allocator,
        curve,
        LINE_SEGMENTS_PER_LINE,
    ) catch unreachable;
}

export fn game_update(delta_time: f32) void {
    _ = delta_time;
    // Update game logic
    const mouse = ray.GetMousePosition();

    if (ray.IsMouseButtonDown(ray.MOUSE_BUTTON_LEFT)) {
        if (isMouseOverPoint(curve.start, mouse)) {
            curve.start.x = mouse.x;
            curve.start.y = mouse.y;

            lineSegments = bezier.curveToLineSegments(
                persistent_allocator,
                curve,
                LINE_SEGMENTS_PER_LINE,
            ) catch unreachable;
        }
    }
}

export fn game_draw() void {
    for (lineSegments) |line| {
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

    _ = frame_arena.reset(.retain_capacity);
}

export fn game_shutdown() void {
    // Clean up game state
}
