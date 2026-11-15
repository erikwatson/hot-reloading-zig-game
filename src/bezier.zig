const std = @import("std");
const types = @import("./types.zig");

// Single axis only, so the "cp1", etc here don't refer to points, but values
// of those points along a single axis
fn cubicBlend(
    start: f64,
    cp1: f64,
    cp2: f64,
    end: f64,
    position: f64,
) f64 {
    const remainder = 1 - position;
    return (remainder * remainder * remainder * start +
        3 * remainder * remainder * position * cp1 +
        3 * remainder * position * position * cp2 +
        position * position * position * end);
}

fn cubicBezier(curve: types.Curve, position: f64) types.Point {
    return types.Point{ .x = cubicBlend(
        curve.start.x,
        curve.cp1.x,
        curve.cp2.x,
        curve.end.x,
        position,
    ), .y = cubicBlend(
        curve.start.y,
        curve.cp1.y,
        curve.cp2.y,
        curve.end.y,
        position,
    ) };
}

pub fn curveToLineSegments(
    allocator: std.mem.Allocator,
    curve: types.Curve,
    steps: usize,
) ![]types.Line {
    const lines = try allocator.alloc(types.Line, steps);

    // Populate lines with each line segment
    var previousPoint = cubicBezier(curve, 0);

    for (0..steps) |i| {
        const f_steps: f64 = @floatFromInt(steps);
        const f_i: f64 = @floatFromInt(i);
        const t = f_i / f_steps;
        const currentPoint = cubicBezier(curve, t);

        lines[i] = .{
            .start = previousPoint,
            .end = currentPoint,
        };

        previousPoint = currentPoint;
    }

    return lines;
}
