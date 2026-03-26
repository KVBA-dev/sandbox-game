package main

import rl "vendor:raylib"
import "ui"
import "ui/clay"
import "core:fmt"

WindowMode :: enum u8{
	Borderless,
	Fullscreen,
	Windowed,
	__COUNT,
}

Settings :: struct {
	prev_layout_proc: proc(data: rawptr) -> ui.Layout,
	prev_layout_data: rawptr,

	window_mode: WindowMode,
	fps_counter: bool,
}

settings := Settings {}
prev_settings := Settings {}

open_settings_menu :: proc() {
	settings.prev_layout_proc = ui.ui_layout_proc
	settings.prev_layout_data = ui.ui_layout_data
	ui.set_layout(settings_menu_layout, &settings)
}

close_settings_menu :: proc() {
	ui.set_layout(settings.prev_layout_proc, settings.prev_layout_data)
	settings.prev_layout_proc = nil
	settings.prev_layout_data = nil
}

settings_menu_layout :: proc(data: rawptr) -> ui.Layout {
	clay.BeginLayout()

	if clay.UI()({
		layout = {
			sizing = {width = clay.SizingPercent(0.3), height = clay.SizingGrow()},
		}
	}) {}
	
	if clay.UI()({
		layout = {
			sizing = {width = clay.SizingGrow(), height = clay.SizingGrow()},
			layoutDirection = .TopToBottom,
			childGap = 16,
			childAlignment = {x = .Center, y = .Center},
		}
	}) {
		clay.Text("SETTINGS", &ui.text_style_h1)
		ui.Button("ButtonWindowMode", fmt.tprint("Window mode:", settings.window_mode), {
			func = proc(data: rawptr) {
				settings.window_mode = WindowMode((u8(settings.window_mode) + 1) % u8(WindowMode.__COUNT))
				apply_settings()
			},
			data = nil
		})
		ui.Button("ButtonFPSCounter", fmt.tprint("FPS counter:", settings.fps_counter ? "On" : "Off"), {
			func = proc(data: rawptr) {
				settings.fps_counter ~= true
				apply_settings()
			},
			data = nil
		})
		ui.Button("ButtonBack", "Back", {
			func = proc(data: rawptr) {
				close_settings_menu()
			},
			data = nil
		})
	}

	if clay.UI()({
		layout = {
			sizing = {width = clay.SizingPercent(0.3), height = clay.SizingGrow()},
		}
	}) {}
	return clay.EndLayout()
}

load_settings :: proc() {}

save_settings :: proc() {}

apply_settings :: proc() {
	defer prev_settings = settings
	if prev_settings.window_mode != settings.window_mode {
		rl.ClearWindowState({.BORDERLESS_WINDOWED_MODE, .FULLSCREEN_MODE, .WINDOW_RESIZABLE})
		#partial switch settings.window_mode{
		case .Borderless:
			rl.SetWindowState({.BORDERLESS_WINDOWED_MODE})
		case .Fullscreen:
			rl.SetWindowState({.FULLSCREEN_MODE})
		case .Windowed:
			rl.SetWindowState({.WINDOW_RESIZABLE})
		}
	}
}
