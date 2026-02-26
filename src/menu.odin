package main

import rl "vendor:raylib"

Menu_Data :: struct {
	game: ^Game_Data
}

menu_init :: proc(data: rawptr) {
	m := (^Menu_Data)(data)
	m.game = new(Game_Data)
}

menu_update :: proc(data: rawptr) {
	m := (^Menu_Data)(data)

	if rl.IsKeyPressed(.ENTER) {
		push_scene({
			init = game_init,
			update = game_update,
			cleanup = game_cleanup,
			data = m.game,
		})
	}
	if rl.IsKeyPressed(.ESCAPE) {
		pop_scene()
	}

	rl.BeginDrawing()
	{
		rl.ClearBackground(rl.BLUE)
		rl.DrawText("Press Enter to play", 50, 50, 50, rl.WHITE)
		rl.DrawText("Press Esc to exit", 50, 110, 25, rl.WHITE)
	}
	rl.EndDrawing()
}

menu_cleanup :: proc(data: rawptr) {
	m := (^Menu_Data)(data)
	free(m.game)
}
