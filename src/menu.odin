package main

import rl "vendor:raylib"
import "ui"
import "ui/clay"

Menu_Data :: struct {
	game: ^Game_Data
}

menu_init :: proc(data: rawptr) {
	m := (^Menu_Data)(data)
	m.game = new(Game_Data)
}

menu_update :: proc(data: rawptr) {
	m := (^Menu_Data)(data)
	if ui.ui_layout_proc == ui.dummy_proc {
		ui.set_layout(main_menu_ui, m)
	}
	ui.update()

	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLUE)
		ui.render()
	}
	rl.EndDrawing()
}

menu_cleanup :: proc(data: rawptr) {
	m := (^Menu_Data)(data)
	free(m.game)
}

main_menu_ui :: proc(data: rawptr) -> ui.Layout {
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
		clay.Text("SANDBOX GAME", &ui.text_style_h1)
		ui.Button("ButtonPlay", "Play", {
			func = proc(data: rawptr) {
				m := (^Menu_Data)(data)
				scene := GAME_SCENE
				scene.data = m.game
				push_scene(scene)
				ui.set_layout(ui.dummy_proc, nil)
			},
			data = data
		})
		ui.Button("ButtonSettings", "Settings", {
			func = proc(data: rawptr) {
				open_settings_menu()
			},
			data = nil
		})
		ui.Button("ButtonQuit", "Quit", {
			func = proc(data: rawptr) {
				pop_scene()
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
