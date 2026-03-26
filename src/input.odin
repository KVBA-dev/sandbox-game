package main

import rl "vendor:raylib"
import "core:math"

InputState :: enum u8 {
	Game,
	Menu,
	UI,
}

MouseState :: struct {
	chunk_coord: [2]int,
	tile_coord: int,
}

input_state: InputState = .Game
mouse_state: MouseState = {}

handle_mouse :: proc(cam: rl.Camera2D) {
	mouse_pos := rl.GetScreenToWorld2D(rl.GetMousePosition(), cam) / TILE_SIZE
	mouse_state.chunk_coord = [2]int {
		int(math.floor(mouse_pos.x / CHUNK_LENGTH)),
		int(math.floor(mouse_pos.y / CHUNK_LENGTH)),
	}
	x := math.mod(math.floor(mouse_pos.x), CHUNK_LENGTH)
	y := math.mod(math.floor(mouse_pos.y), CHUNK_LENGTH)
	mouse_state.tile_coord = int(CHUNK_LENGTH * y + x)
}

