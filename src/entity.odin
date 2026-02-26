package main

import rl "vendor:raylib"

MAX_ENTITIES :: 10000

Entity :: struct {
	state_machine: Closure(rawptr),
	renderer: Closure(rawptr),
	pos: [2]f32,
}
