package ui

import rl "vendor:raylib"
import "clay"

Layout :: #type clay.ClayArray(clay.RenderCommand)

ui_data: [^]u8
ui_arena: clay.Arena
ui_layout_proc: proc(data:rawptr) -> Layout = dummy_proc
ui_layout_data: rawptr
ui_layout: Layout

dummy_proc :: proc(data: rawptr) -> Layout {
	clay.BeginLayout()
	return clay.EndLayout()
}

init :: proc() {
	mem_size := clay.MinMemorySize()
	ui_data = make([^]u8, mem_size)
	ui_arena = clay.CreateArenaWithCapacityAndMemory(uint(mem_size), ui_data)
    clay.Initialize(ui_arena, {width = f32(rl.GetScreenWidth()), height = f32(rl.GetScreenHeight())}, {})
    clay.SetMeasureTextFunction(MeasureText, nil)

	LoadFont("res/fonts/Roboto.ttf")
}

update :: proc() {
	clay.SetLayoutDimensions({width = f32(rl.GetScreenWidth()), height = f32(rl.GetScreenHeight())})
	clay.SetPointerState(rl.GetMousePosition(), rl.IsMouseButtonPressed(.LEFT))
	clay.UpdateScrollContainers(true, rl.GetMouseWheelMoveV(), rl.GetFrameTime())

	when ODIN_DEBUG {
		if rl.IsKeyPressed(.F11) {
			clay.SetDebugModeEnabled(!clay.IsDebugModeEnabled())
		}
	}

	ui_layout = ui_layout_proc(ui_layout_data)
}

set_layout :: proc(layout: proc(data: rawptr) -> Layout, data: rawptr) {
	ui_layout_proc = layout
	ui_layout_data = data
}

render :: proc() {
	Render(&ui_layout)
}

destroy :: proc() {
	UnloadFonts()
	free(ui_data)
}
