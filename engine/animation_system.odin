package engine

import rl "vendor:raylib"

Animation :: struct {
	start: i32, // first frame idx on sheet
	end:   i32, // last frame idx, inclusive
	fps:   f32,
	loop:  bool,
}

Spriteframes :: struct {
	texture: rl.Texture2D,
	frame_w: i32,
	frame_h: i32,
	cols:    i32,
	anims:   map[string]Animation,
}

load_spriteframes :: proc(path: cstring, frame_w, frame_h: i32) -> Spriteframes {
	tex := rl.LoadTexture(path)
	return Spriteframes {
		texture = tex,
		frame_w = frame_w,
		frame_h = frame_h,
		cols = tex.width / frame_w,
	}
}

add_anim :: proc(sf: ^Spriteframes, name: string, start, end: i32, fps: f32, loop := true) {
	sf.anims[name] = Animation{start, end, fps, loop} // nil map allocate on first insert
}

// per-entity playback state
Animator :: struct {
	current:  string,
	frame:    i32, // offset inside current anim
	timer:    f32,
	finished: bool,
}

play :: proc(a: ^Animator, name: string) {
	if a.current == name do return // already playing, no restart
	a.current = name
	a.frame = 0
	a.timer = 0
	a.finished = false
}

update_animator :: proc(a: ^Animator, sf: ^Spriteframes, dt: f32) {
	anim, ok := sf.anims[a.current]
	if !ok || a.finished do return

	a.timer += dt
	frame_time := 1.0 / anim.fps
	last := anim.end - anim.start

	for a.timer >= frame_time {
		a.timer -= frame_time
		a.frame += 1
		if a.frame > last {
			if anim.loop {
				a.frame = 0
			} else {
				a.frame = last
				a.finished = true
				break
			}
		}
	}
}

draw_animator :: proc(sf: ^Spriteframes, a: Animator, pos: rl.Vector2) {
	anim, ok := sf.anims[a.current]
	if !ok do return

	idx := anim.start + a.frame
	src := rl.Rectangle {
		f32((idx % sf.cols) * sf.frame_w), // col = idx % cols
		f32((idx / sf.cols) * sf.frame_h), // row = idx / cols
		f32(sf.frame_w),
		f32(sf.frame_h),
	}
	rl.DrawTextureRec(sf.texture, src, pos, rl.WHITE)
}
