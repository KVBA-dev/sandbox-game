package main

import rl "vendor:raylib"

get_screen_rect :: proc() -> rl.Rectangle {
	return {
		x = 0,
		y = 0,
		width = f32(rl.GetScreenWidth()),
		height = f32(rl.GetScreenHeight()),
	}
}

