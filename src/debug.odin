package main

import rl "vendor:raylib"

DebugInfo :: struct {
	drawn_chunks: int,
}

debug_info: DebugInfo

draw_debug_info :: proc() {
	when ODIN_DEBUG {
		rl.DrawText(rl.TextFormat("Drawn chunks: %d", debug_info.drawn_chunks), 10, rl.GetScreenHeight() - 30, 20, rl.BLACK)
	}
}
