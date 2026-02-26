package main

Scene :: struct {
	init: proc(data: rawptr),
	update: proc(data: rawptr),
	cleanup: proc(data: rawptr),
	data: rawptr,

	needs_cleanup: bool,
}

scene_stack: [16]Scene
scene_stack_size: int = 0

push_scene :: proc(s: Scene) -> bool {
	if scene_stack_size >= 16 {
		return false
	}

	scene_stack[scene_stack_size] = s
	scene_stack_size += 1
	s.init(s.data)
	return true
}

pop_scene :: proc() -> (scene: Scene, ok: bool) {
	if scene_stack_size == 0 {
		return {}, false
	}

	s := &scene_stack[scene_stack_size - 1]
	scene_stack_size -= 1
	s.needs_cleanup = true
	return s^, true
}

set_scene :: proc(scene: Scene) {
	pop_scene()
	push_scene(scene)
}

current_scene :: proc() -> ^Scene {
	if scene_stack_size == 0 {
		return nil
	}
	return &scene_stack[scene_stack_size - 1]
}
