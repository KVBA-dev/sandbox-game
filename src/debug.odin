package main

import rl "vendor:raylib"
import "core:time"

AVG_FRAME_COUNT :: 500

DebugInfo :: struct {
	drawn_chunks: int,
	last_tick: time.Time,
	last_frame_duration: time.Duration,
	last_n_frames: [AVG_FRAME_COUNT]time.Duration,
	last_n_frames_idx: int,
	last_processing_tick: time.Time,
	last_processing_duration: time.Duration,
	generating_time: time.Duration,
}

debug_info: DebugInfo

draw_debug_info :: proc() {
	when ODIN_DEBUG {
		frames_avg: f64
		for f in debug_info.last_n_frames {
			frames_avg += time.duration_milliseconds(f)
		}
		frames_avg /= AVG_FRAME_COUNT

		info_strings := []cstring{
			rl.TextFormatAlloc("Drawn chunks: %d", debug_info.drawn_chunks),
			rl.TextFormatAlloc("Last %d frames average: %.2f ms", AVG_FRAME_COUNT, time.duration_milliseconds(debug_info.last_frame_duration)),
			rl.TextFormatAlloc("Last frame duration: %.2f ms", time.duration_milliseconds(debug_info.last_frame_duration)),
			rl.TextFormatAlloc("Processing time: %.2f us", time.duration_microseconds(debug_info.last_processing_duration)),
			rl.TextFormatAlloc("Generating time: %.2f ms", time.duration_milliseconds(debug_info.generating_time)),
		}
		defer for is in info_strings {
			rl.MemFreeCstring(is)
		}
		rect_height := f32(len(info_strings) * 20 + (len(info_strings) - 1) * 5 + 20)
		bg_rect := rl.Rectangle{
			x = 0,
			y = f32(rl.GetScreenHeight()) - rect_height,
			width = 500,
			height = rect_height,
		}
		offset: i32 = 30
		rl.DrawRectangleRec(bg_rect, rl.ColorAlpha(rl.BLACK, 0.5))
		for is in info_strings {
			rl.DrawText(is, 10, rl.GetScreenHeight() - offset, 20, rl.WHITE)
			offset += 25
		}
	}
}


