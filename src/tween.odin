package main

TweenSequence :: struct {}

TweenAction :: union {
	TweenAction_Type(f32),
	TweenAction_Type([2]f32),
	TweenAction_Type([3]f32),
	TweenAction_Type([4]f32),
}

TweenAction_Type :: struct($T: typeid) {
	target: ^T,
	endValue: T,
}
