const ray = @import("ray");
const imgui = @import("imgui");

pub fn main() void {
    const screen_width = 1280;
    const screen_height = 720;

    ray.InitWindow(screen_width, screen_height, "Arena");
    defer ray.CloseWindow();

    imgui.imgui_init();
    defer imgui.imgui_shutdown();

    ray.SetTargetFPS(60);

    var editor_enabled = true;

    while (!ray.WindowShouldClose()) {
        if (ray.IsKeyPressed(ray.KEY_E)) {
            editor_enabled = !editor_enabled;
        }

        ray.BeginDrawing();
        ray.ClearBackground(ray.RAYWHITE);

        ray.DrawText("Hello, Zig + raylib!", 400, 330, 30, ray.DARKGRAY);

        if (editor_enabled) {
            imgui.imgui_begin();
            imgui.imgui_draw_debug();
            imgui.imgui_end();
        }

        ray.EndDrawing();
    }
}
