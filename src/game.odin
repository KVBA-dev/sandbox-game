package main

import rl "vendor:raylib"
import la "core:math/linalg"
import "core:time"
import "ui"
import "ui/clay"

GAME_SCENE :: Scene {
	init = game_init,
	update = game_update,
	cleanup = game_cleanup,
}

Game_Data :: struct {
	world: World,
	camera: rl.Camera2D,
	player: Player,
	entities: []Entity,
	paused: bool,
}

game_init :: proc(data: rawptr) {
	g := (^Game_Data)(data)

	g.camera = rl.Camera2D {
		zoom = 3,
		rotation = 0,
		offset = (rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())} * 0.5),
		target = {0, 0},
	}
	g.world = World {
		layers = make([]WorldLayer, 1)
	}

	when ODIN_DEBUG {
		generating_start := time.now()
	}
	generate_world_layer(&g.world.layers[0])
	when ODIN_DEBUG {
		debug_info.generating_time = time.since(generating_start)
	}

	g.player = Player{
		inventory = make([]ItemSlot, 40)
	}
	g.entities = make([]Entity, MAX_ENTITIES)
	input_state = .Game

}
	
game_cleanup :: proc(data: rawptr) {
	g := (^Game_Data)(data)
	delete(g.entities)
	delete(g.player.inventory)
	destroy_world(&g.world)
}

game_update :: proc(data: rawptr) {
	g := (^Game_Data)(data)

	ui.update()
	
	dt := rl.GetFrameTime()
	
	when ODIN_DEBUG {
		debug_info.last_processing_tick = time.now()
	}
	g.camera.target = la.lerp(g.camera.target, g.player.pos * TILE_SIZE, 5 * dt)

	/*
	for e in entities {
		if e.state_machine != {} {
			e.state_machine.func(e.state_machine.data)
		}
	}
	*/

	switch input_state {
	case .Game:
		player_movement(&g.player)
		handle_mouse(g.camera)
		if rl.IsKeyPressed(.E) {
			input_state = .UI
		}
		if rl.IsKeyPressed(.ESCAPE) {
			input_state = .Menu
			g.paused = true
			ui.set_layout(pause_menu_ui, g)
		}
	case .Menu:
		if rl.IsKeyPressed(.ESCAPE) {
			if settings.prev_layout_proc == nil {
				input_state = .Game
				g.paused = false
				ui.set_layout(ui.dummy_proc, nil)
			}
			else {
				close_settings_menu()
			}
		}
	case .UI:
		if rl.IsKeyPressed(.ESCAPE) || rl.IsKeyPressed(.E) {
			input_state = .Game
		}
	}
	when ODIN_DEBUG {
		debug_info.last_processing_duration = time.since(debug_info.last_processing_tick)
	}
	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.WHITE)
		rl.BeginMode2D(g.camera)
		{
			world_layer_render(&g.world.layers[0], &g.camera)
			/*
			for e in entities {
				if e.renderer != {} {
					e.renderer.func(e.renderer.data)
				}
			}
			*/
			player_render(&g.player)
		}
		rl.EndMode2D()

		draw_debug_info()
		if settings.fps_counter {
			rl.DrawFPS(10, 10)
		}
		switch input_state {
		case .Game:
		case .Menu:
			rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.ColorAlpha(rl.BLACK, 0.5))
		case .UI:
			rl.DrawRectangle(0, 0, rl.GetScreenWidth(), rl.GetScreenHeight(), rl.ColorAlpha(rl.BLACK, 0.5))
			player_inventory_render(g.player.inventory, {})
		}
		ui.render()
	}
	rl.EndDrawing()
	when ODIN_DEBUG {
		debug_info.last_frame_duration = time.since(debug_info.last_tick)
		debug_info.last_n_frames[debug_info.last_n_frames_idx] = debug_info.last_frame_duration
		debug_info.last_n_frames_idx = (debug_info.last_n_frames_idx + 1) % AVG_FRAME_COUNT
		debug_info.last_tick = time.now()
	}
}

pause_menu_ui :: proc(data: rawptr) -> ui.Layout {
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
		clay.Text("PAUSE", &ui.text_style_h1)
		ui.Button("ButtonResume", "Resume", {
			func = proc(data: rawptr) {
				g := (^Game_Data)(data)
				input_state = .Game
				g.paused = false
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
				ui.set_layout(ui.dummy_proc, nil)
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
