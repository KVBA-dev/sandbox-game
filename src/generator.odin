package main

import "core:math"
import "core:thread"
import "core:sync"
import "core:math/noise"
import "perlin"

ChunkGeneratorContext :: struct {
	layer: ^WorldLayer,
	coords: [][2]int,
	chunk_mtx: sync.Mutex,
	noise: perlin.Noise,
	noise_scale: f64,
	octaves: int,
}

generate_world_layer :: proc(layer: ^WorldLayer) {
	INITIAL_LAYER_SIZE :: 35

	layer.chunks = make(map[[2]int]WorldChunk)

	ctx := ChunkGeneratorContext {
		layer = layer,
		coords = make([][2]int, INITIAL_LAYER_SIZE * INITIAL_LAYER_SIZE),
		noise_scale = 0.01,
		octaves = 4
	}
	perlin.init(&ctx.noise, 1111)
	defer delete(ctx.coords)

	pool: thread.Pool
	thread.pool_init(&pool, context.allocator, 8)
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
		t := f32(perlin.noise_vec(&ctx.noise, noise.Vec2{f64(nx), f64(ny)} * ctx.noise_scale, 5))
		t = math.smoothstep(f32(0), 1, t)
		switch t{
		case .8..=1:
			chunk.base_tiles[i] = .Stone
		case .6..<.8:
			chunk.base_tiles[i] = .Grass
		case .525..<.6:
			chunk.base_tiles[i] = .Sand
		case 0..<.525:
			chunk.base_tiles[i] = .Water
		}
	}
	if sync.mutex_guard(&ctx.chunk_mtx) {
		ctx.layer.chunks[coords] = chunk
	}
	
}

func_blend :: proc(x: f32, a, b: proc(_: f32) -> f32, t: f32) -> f32 {
	return math.lerp(a(x), b(x), t)
}

linear :: proc(x :f32) -> f32 {
	return x
}

plateau :: proc(x: f32) -> f32 {
	return 4 * math.pow(x - 0.5, 3) + 0.5
}
