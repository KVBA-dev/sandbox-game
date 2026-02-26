package main

import rl "vendor:raylib"
import la "core:math/linalg"
import "core:time"

Game_Data :: struct {
	world: World,
	camera: rl.Camera2D,
	player: Player,
	entities: []Entity,
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

	g.player = Player{}
	g.entities = make([]Entity, MAX_ENTITIES)
}
	
game_cleanup :: proc(data: rawptr) {
	g := (^Game_Data)(data)
	delete(g.entities)
	destroy_world(&g.world)
}

game_update :: proc(data: rawptr) {
	g := (^Game_Data)(data)
	
		dt := rl.GetFrameTime()
		
		if rl.IsKeyPressed(.ESCAPE) {
			pop_scene()
		}

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

		player_movement(&g.player)
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

			rl.DrawFPS(10, 10)
			draw_debug_info()
			
		}
		rl.EndDrawing()
		when ODIN_DEBUG {
			debug_info.last_frame_duration = time.since(debug_info.last_tick)
			debug_info.last_n_frames[debug_info.last_n_frames_idx] = debug_info.last_frame_duration
			debug_info.last_n_frames_idx = (debug_info.last_n_frames_idx + 1) % AVG_FRAME_COUNT
			debug_info.last_tick = time.now()
		}
}
