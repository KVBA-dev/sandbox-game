package perlin

import "core:math"
import n "core:math/noise"
import "core:math/rand"

// implementation based on
// https://en.wikipedia.org/wiki/Perlin_noise

PERMUTATION_LENGTH :: 1024

Noise :: struct {
    permutation: [2*PERMUTATION_LENGTH]i32
}

init :: proc(gen: ^Noise, seed: u64) {
    p: [PERMUTATION_LENGTH]i32 = {}
    state := rand.create(seed)
    rnd_gen := rand.default_random_generator(&state)
    for i in 0..<PERMUTATION_LENGTH {
        p[i] = i32(i)
    }
    idx: int
    for i in 0..<PERMUTATION_LENGTH - 1 {
        idx = rand.int_max(PERMUTATION_LENGTH - i, rnd_gen) + i
        temp := p[i]
        p[i] = p[idx]
        p[idx] = temp 

        gen.permutation[i] = p[i]
        gen.permutation[i + PERMUTATION_LENGTH] = p[i]
    }
}

@(private)
rand_vec :: proc(gen: ^Noise, ix, iy: i32) -> (x, y: f64) {
    ix := ix % PERMUTATION_LENGTH
    if ix < 0 {
        ix += PERMUTATION_LENGTH
    }
    iy := iy % PERMUTATION_LENGTH
    if iy < 0 {
        iy += PERMUTATION_LENGTH
    }
    hash := gen.permutation[ix + gen.permutation[iy]]
    phi := f64(hash) * math.TAU / f64(PERMUTATION_LENGTH - 1)

    return math.cos(phi), math.sin(phi)
}

@(private)
interpolate :: proc(a0, a1, w: f64) -> f64 {
    w := w * math.PI
    w = (1 - math.cos(w)) / 2
    return (a1 - a0) * w + a0
}

@(private)
dot :: proc(gen: ^Noise, ix, iy: i32, x, y: f64) -> f64 {
    vx, vy := rand_vec(gen, ix, iy)
    dx := x - f64(ix)
    dy := y - f64(iy)
    return dx * vx + dy * vy
}

noise_f64 :: proc(gen: ^Noise, x, y: f64, octaves: u8) -> f64 {
    // this function returns a value in [0, 1] range
    // meaning 0.5 is a mid-point
    if octaves == 0 {
        return 0.5
    }
    x0 := i32(math.floor(x))
    x1 := x0 + 1
    y0 := i32(math.floor(y))
    y1 := y0 + 1

    wx := x - f64(x0)
    wy := y - f64(y0)
    n0 := dot(gen, x0, y0, x, y)
    n1 := dot(gen, x1, y0, x, y)
    ix0 := interpolate(n0, n1, wx)

    n0 = dot(gen, x0, y1, x, y)
    n1 = dot(gen, x1, y1, x, y)
    ix1 := interpolate(n0, n1, wx)

    return (interpolate(ix0, ix1, wy) + noise(gen, x * 2, y * 2, octaves - 1) -.5) * .5 + .5 
}

noise_vec :: proc(gen: ^Noise, v: n.Vec2, octaves: u8) -> f64 {
    return noise_f64(gen, f64(v.x), f64(v.y), octaves)
}

noise :: proc{noise_f64, noise_vec}
