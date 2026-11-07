#include "rlImGui.h"
#include "imgui.h"

extern "C" {

  void imgui_init(void) {
    rlImGuiSetup(true);
    ImGui::GetIO().ConfigFlags |= ImGuiConfigFlags_DockingEnable;
    ImGui::GetStyle().Colors[ImGuiCol_DockingEmptyBg].w = 0.0f;
    ImGui::SetNextWindowBgAlpha(0.0f);
  }

  void imgui_begin(void) {
    rlImGuiBegin();
  }

  void imgui_draw_debug(void) {
    ImGui::DockSpaceOverViewport(0, ImGui::GetMainViewport());
    ImGui::Begin("Debug");

    ImGui::Text("Dear ImGui is running!");
    ImGui::Text("FPS: %.1f", ImGui::GetIO().Framerate);

    ImGui::End();
  }

  void imgui_end(void) {
    rlImGuiEnd();
  }

  void imgui_shutdown(void) {
    rlImGuiShutdown();
  }

}
