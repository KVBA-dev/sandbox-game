package main

import rl "vendor:raylib"

Player :: struct {
	pos: [2]f32,
	health: f32,
}

player_movement :: proc(player: ^Player) {
	switch input_state {
	case .Game:
		dt := rl.GetFrameTime()

		speed :: 5

		if rl.IsKeyDown(.W) {
			player.pos.y -= speed * dt
		}
		if rl.IsKeyDown(.S) {
			player.pos.y += speed * dt
		}
		if rl.IsKeyDown(.A) {
			player.pos.x -= speed * dt
		}
		if rl.IsKeyDown(.D) {
			player.pos.x += speed * dt
		}
	case .Menu, .UI:
	}
}

player_render :: proc(player: ^Player) {
	pos := player.pos * TILE_SIZE
	rl.DrawRectangleV({pos.x, pos.y}, {TILE_SIZE, TILE_SIZE}, rl.RED)
}
