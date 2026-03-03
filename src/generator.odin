package main

import "core:math"
import "core:thread"
import "core:sync"
import "core:math/noise"

ChunkGeneratorContext :: struct {
	layer: ^WorldLayer,
	coords: [][2]int,
	chunk_mtx: sync.Mutex,
	noise_scale: f64,
	noise_seed: i64,
}

generate_world_layer :: proc(layer: ^WorldLayer) {
	INITIAL_LAYER_SIZE :: 25

	layer.chunks = make(map[[2]int]WorldChunk)

	ctx := ChunkGeneratorContext {
		layer = layer,
		coords = make([][2]int, INITIAL_LAYER_SIZE * INITIAL_LAYER_SIZE),
		noise_scale = 0.025,
		noise_seed = 2
	}
	defer delete(ctx.coords)

	pool: thread.Pool
	thread.pool_init(&pool, context.allocator, 6)
	defer thread.pool_destroy(&pool)

	for &c, i in ctx.coords {
		c = [2]int{i % INITIAL_LAYER_SIZE - (INITIAL_LAYER_SIZE / 2), i / INITIAL_LAYER_SIZE - (INITIAL_LAYER_SIZE / 2)}
		thread.pool_add_task(&pool, context.allocator, generate_chunk, &ctx, i)
	}

	thread.pool_start(&pool)
	thread.pool_finish(&pool)

}

generate_chunk :: proc(task: thread.Task) {
	ctx := (^ChunkGeneratorContext)(task.data)
	coords := ctx.coords[task.user_index]
	chunk := WorldChunk {
		base_tiles = make([]Tile, CHUNK_AREA)
	}


	for i in 0..<CHUNK_AREA {
		x := i % CHUNK_LENGTH
		y := i / CHUNK_LENGTH

		nx := coords.x * CHUNK_LENGTH + x
		ny := coords.y * CHUNK_LENGTH + y
		t := f32(noise.noise_2d(ctx.noise_seed, noise.Vec2{f64(nx), f64(ny)} * ctx.noise_scale)) * 0.5 + 0.5
		t += f32(noise.noise_2d(ctx.noise_seed, noise.Vec2{f64(nx), f64(ny)} * ctx.noise_scale * 2)) * 0.3
		t += f32(noise.noise_2d(ctx.noise_seed, noise.Vec2{f64(nx), f64(ny)} * ctx.noise_scale * 4)) * 0.09
		t = math.clamp(t, 0, 1)
		t = plateau(t)
		switch t{
		case .7..=1:
			chunk.base_tiles[i] = .Stone
		case .5..<.7:
			chunk.base_tiles[i] = .Grass
		case .4..<.5:
			chunk.base_tiles[i] = .Sand
		case 0..<.4:
			chunk.base_tiles[i] = .Water
		}
	}
	if sync.mutex_guard(&ctx.chunk_mtx) {
		ctx.layer.chunks[coords] = chunk
	}
	
}

plateau :: proc(x: f32) -> f32 {
	return 4 * math.pow(x - 0.5, 3) + 0.5
}
