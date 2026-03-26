package main

import rl "vendor:raylib"
import "core:fmt"
import fp "core:path/filepath"
import "core:strings"
import "base:intrinsics"

TILE_SIZE :: 16

atlas_registry: [8]rl.Texture

generate_texture_atlas :: proc(base_directory: string, start_offset: $T) -> rl.Texture 
  where intrinsics.type_is_enum(T) {
	img := rl.GenImageColor(1024, 1024, {})
	defer rl.UnloadImage(img)

	buf: [256]u8
	for t in T {
		if t < start_offset {
			continue
		}
		if u16(t) >= u16(start_offset) + 4096 {
			break
		}

		idx := u16(t) % 4096
		x := idx % 64
		y := idx / 64

		filename := fmt.ctprint(
			fp.join({
				base_directory, 
				strings.to_kebab_case(
					fmt.bprintf(buf[:], "%v.png", t), 
				context.temp_allocator),
			}, 
			context.temp_allocator)
		)
		tex := rl.LoadImage(filename)
		if !rl.IsImageValid(tex) {
			free_all(context.temp_allocator)
			continue
		}
		rl.ImageDraw(&img, tex, rl.Rectangle{0, 0, TILE_SIZE, TILE_SIZE}, rl.Rectangle{f32(x * TILE_SIZE), f32(y * TILE_SIZE), TILE_SIZE, TILE_SIZE}, rl.WHITE)
		rl.UnloadImage(tex)
		free_all(context.temp_allocator)
	}

	return rl.LoadTextureFromImage(img)
}
