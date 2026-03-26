package ui

import "clay"
import "../closure"
import rl "vendor:raylib"

Button :: proc(id: string, caption: string, onclick: closure.Closure(rawptr)) {
	_id := clay.ID(id)
	hover := clay.PointerOver(_id)
	col: clay.Color = {0, 0, 0, 0}
	if hover {
		col = clay.Color {255, 255, 255, 100}
		if rl.IsMouseButtonPressed(.LEFT) {
			onclick.func(onclick.data)
		}
	}
	if clay.UI(_id)({
		layout = {
			sizing = {width = clay.SizingGrow(), height = clay.SizingFit()},
			padding = clay.PaddingAll(16),
			childAlignment = {x = .Center, y = .Center},
		},
		border = {
			color = clay.Color{255, 255, 255, 100},
			width = clay.BorderAll(4),
		},
		backgroundColor = col,
	}) {
		clay.TextDynamic(caption, &text_style)
	}
}
