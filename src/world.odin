package main

import rl "vendor:raylib"
import "core:math"

CHUNK_LENGTH :: 16
CHUNK_AREA :: CHUNK_LENGTH * CHUNK_LENGTH
CHUNK_PIXEL_LENGTH :: CHUNK_LENGTH * TILE_SIZE

World :: struct {
	layers: []WorldLayer
}

WorldLayer :: struct {
	chunks: map[[2]int]WorldChunk
}

WorldChunk :: struct {
	base_tiles: []Tile,
	decor_tiles: []Tile,
}

world_layer_render :: proc(layer: ^WorldLayer, cam: ^rl.Camera2D) {
	
	min_point_screen := rl.GetScreenToWorld2D({0, 0}, cam^)
	max_point_screen := rl.GetScreenToWorld2D({f32(rl.GetScreenWidth()), f32(rl.GetScreenHeight())}, cam^)
	min_point_chunk := world_point_to_chunk_coord(min_point_screen)
	max_point_chunk := world_point_to_chunk_coord(max_point_screen)

	for x in min_point_chunk.x ..= max_point_chunk.x {
		for y in min_point_chunk.y ..= max_point_chunk.y {
			coord := [2]int{x, y}
			c, chunk_ok := layer.chunks[coord]
			if !chunk_ok {
				// TODO: query chunk generation
				continue
			}
			min_point := rl.Vector2{f32(coord.x) * CHUNK_PIXEL_LENGTH, f32(coord.y) * CHUNK_PIXEL_LENGTH}

			for t, t_idx in c.base_tiles {
				atlas_idx := u16(t) / 4096
				atlas_tex := atlas_registry[atlas_idx]
				atlas_x := f32(u16(t) % 64)
				atlas_y := f32(u16(t) / 64)
				tex_x := f32(t_idx % CHUNK_LENGTH)
				tex_y := f32(t_idx / CHUNK_LENGTH)
				rl.DrawTexturePro(
					atlas_tex,
					rl.Rectangle{atlas_x * TILE_SIZE, atlas_y * TILE_SIZE, TILE_SIZE, TILE_SIZE},
					rl.Rectangle{
						min_point.x + tex_x * TILE_SIZE,
						min_point.y + tex_y * TILE_SIZE,
						TILE_SIZE,
						TILE_SIZE,
					},
					{},
					0,
					rl.WHITE,
				)
			}
		}
	}
	debug_info.drawn_chunks = (max_point_chunk.x - min_point_chunk.x + 1) * (max_point_chunk.y - min_point_chunk.y + 1)
}

world_point_to_chunk_coord :: proc(point: rl.Vector2) -> [2]int {
	return [2]int{
		int(math.floor(point.x / CHUNK_PIXEL_LENGTH)),
		int(math.floor(point.y / CHUNK_PIXEL_LENGTH)),
	}
}

destroy_world :: proc(w: ^World) {
	for &l in w.layers {
		for _, &c in l.chunks {
			delete(c.base_tiles)
			delete(c.decor_tiles)
		}
		delete(l.chunks)
	}
	delete(w.layers)
}
