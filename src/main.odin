package main

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"

main :: proc() {
	when ODIN_DEBUG {
		rl.SetTraceLogLevel(.DEBUG)
	}
	else {
		rl.SetTraceLogLevel(.NONE)
	}
	rl.InitWindow(800, 600, "Sanbox Game Thing")
	rl.SetWindowState({.BORDERLESS_WINDOWED_MODE})
	defer rl.CloseWindow()

	when ODIN_DEBUG {
		track_alloc: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track_alloc, context.allocator)
		context.allocator = mem.tracking_allocator(&track_alloc)

		defer {
			if len(track_alloc.allocation_map) > 0 {
				fmt.eprintf("%ALLOCATIONS NOT FREED: %v\n", len(track_alloc.allocation_map))
				for _, entry in track_alloc.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track_alloc.bad_free_array) > 0 {
				fmt.eprintf("BAAD FREES: %v\n", len(track_alloc.bad_free_array))
				for entry in track_alloc.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track_alloc)
		}
	}
	rl.SetExitKey(nil)

	monitor := rl.GetCurrentMonitor()
	rl.SetWindowSize(rl.GetMonitorWidth(monitor), rl.GetMonitorHeight(monitor))
	// rl.SetTargetFPS(60)

	atlas_registry[0] = generate_texture_atlas("res/textures", Tile(0))
	defer {
		for tex in atlas_registry {
			rl.UnloadTexture(tex)
		}
	}

	running: bool = true

	menu_data: Menu_Data

	set_scene({
		init = menu_init,
		update = menu_update,
		cleanup = menu_cleanup,
		data = &menu_data,
	})

	for running {
		if rl.WindowShouldClose() {
			running = false
		}
		s := current_scene()
		s.update(s.data)
		if s.needs_cleanup {
			s.cleanup(s.data)
		}
		if scene_stack_size == 0 {
			running = false
		}
		
	}
	for scene_stack_size > 0 {
		pop_scene()
	}
}
