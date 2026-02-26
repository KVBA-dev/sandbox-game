package main

import "core:thread"
import rl "vendor:raylib"
import "core:sync"

ChunkGeneratorContext :: struct {
	layer: ^WorldLayer,
	coords: [][2]int,
	chunk_mtx: sync.Mutex,
	noise_scale: f32,
}

generate_world_layer :: proc(layer: ^WorldLayer) {
	INITIAL_LAYER_SIZE :: 25

	layer.chunks = make(map[[2]int]WorldChunk)

	ctx := ChunkGeneratorContext {
		layer = layer,
		coords = make([][2]int, INITIAL_LAYER_SIZE * INITIAL_LAYER_SIZE),
		noise_scale = 0.15
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

	noise := rl.GenImagePerlinNoise(
		CHUNK_LENGTH, 
		CHUNK_LENGTH, 
		i32(coords.x * CHUNK_LENGTH), 
		i32(coords.y * CHUNK_LENGTH), 
		ctx.noise_scale,
	)
	defer rl.UnloadImage(noise)
	for i in 0..<CHUNK_AREA {
		x := i % CHUNK_LENGTH
		y := i / CHUNK_LENGTH

		t := f32(rl.GetImageColor(noise, i32(x), i32(y)).x) / 255
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
