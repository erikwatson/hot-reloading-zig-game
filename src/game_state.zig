const std = @import("std");
const types = @import("./types.zig");

pub const GameState = struct {
    persistent_arena: std.heap.ArenaAllocator,
    frame_arena: std.heap.ArenaAllocator,

    curve: types.Curve,
    line_segments: []types.Line = &.{},

    pub fn init() GameState {
        return .{
            .persistent_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
            .frame_arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),

            .curve = .{
                .start = .{ .x = 100, .y = 100 },
                .cp1 = .{ .x = 130, .y = 75 },
                .cp2 = .{ .x = 750, .y = 325 },
                .end = .{ .x = 1000, .y = 100 },
            },
        };
    }

    pub fn deinit(self: *GameState) void {
        self.frame_arena.deinit();
        self.persistent_arena.deinit();
    }
};
