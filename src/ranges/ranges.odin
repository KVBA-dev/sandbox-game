package ranges

import "core:sort"

RangeStep :: struct($T: typeid) {
	threshold: f32,
	data: T,
}

Ranges :: struct($T: typeid) {
	r: [dynamic]RangeStep(T),
}

init :: proc(r: ^Ranges($T)) {
	r.r = make([dynamic]RangeStep(T))
}

destroy :: proc(r: ^Ranges($T)) {
	delete(r.r)
}

add_lt :: proc(r: ^Ranges($T), thresh: f32, data: T) {
	append(&r.r, RangeStep(T) {
		threshold = thresh,
		data = data,
	})
	it := sort.Interface {
		collection = &r.r,
		len = proc(i: sort.Interface) -> int {
			slice := (cast(^[dynamic]RangeStep(T))i.collection)^
			return len(slice)
		},
		less = proc(i: sort.Interface, a, b: int) -> bool {
			slice := (cast(^[dynamic]RangeStep(T))i.collection)^
			return slice[a].threshold < slice[b].threshold
		},
		swap = proc(i: sort.Interface, a, b: int) {
			slice := (cast(^[dynamic]RangeStep(T))i.collection)^
			temp := slice[a]
			slice[a] = slice[b]
			slice[b] = temp
		},
	}
	sort.sort(it)
}

eval :: proc(r: ^Ranges($T), t: f32, default: T) -> T {
	for range in r.r {
		if range.threshold > t {
			return range.data
		}
	}
	return default
}
