package main

import rl "vendor:raylib"
import "core:fmt"
import "core:mem"
import la "core:math/linalg"

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
	else {
		// rl.SetExitKey(nil)
	}

	monitor := rl.GetCurrentMonitor()
	rl.SetWindowSize(rl.GetMonitorWidth(monitor), rl.GetMonitorHeight(monitor))
	// rl.SetTargetFPS(60)

	atlas_registry[0] = generate_texture_atlas("res/textures", Tile(0))
	defer {
		for tex in atlas_registry {
			rl.UnloadTexture(tex)
		}
	}

	camera := rl.Camera2D {
		zoom = 3,
		rotation = 0,
		offset = (rl.Vector2{f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())} * 0.5),
		target = {0, 0},
	}

	world := World {
		layers = make([]WorldLayer, 1)
	}
	generate_world_layer(&world.layers[0])
	defer destroy_world(&world)

	player := Player{}
	entities := make([]Entity, MAX_ENTITIES)
	defer delete(entities)

	running: bool = true

	for running {
		dt := rl.GetFrameTime()
		if rl.WindowShouldClose() {
			running = false
		}

		camera.target = la.lerp(camera.target, player.pos * TILE_SIZE, 5 * dt)

		/*
		for e in entities {
			if e.state_machine != {} {
				e.state_machine.func(e.state_machine.data)
			}
		}
		*/

		player_movement(&player)
		rl.BeginDrawing()
		{
			rl.ClearBackground(rl.WHITE)
			rl.BeginMode2D(camera)
			{
				world_layer_render(&world.layers[0], &camera)
				/*
				for e in entities {
					if e.renderer != {} {
						e.renderer.func(e.renderer.data)
					}
				}
				*/
				player_render(&player)
			}
			rl.EndMode2D()

			rl.DrawFPS(10, 10)
			draw_debug_info()
			
		}
		rl.EndDrawing()
	}

}
