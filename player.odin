package game

import eng "engine"

Player_State :: enum {
	IDLE,
	MOVE,
}

Player :: struct {
	pos:   [2]f32,
	speed: f32,
	sf:    eng.Spriteframes,
	anim:  eng.Animator,
	state: Player_State,
}

player: Player

setup_player :: proc(path: cstring) {
	player = Player {
		pos   = {500, 500},
		speed = 150,
		state = .IDLE,
	}
	player.sf = eng.load_spriteframes(path, 32, 32)
	eng.add_anim(&player.sf, "idle", 0, 0, 1)
	eng.add_anim(&player.sf, "move", 13, 25, 12) 
	eng.play(&player.anim, "idle")
}

player_update :: proc(dt: f32, p: ^Player, dir: [2]f32) {
	p.pos += dir * p.speed * dt

	// state from input
	if dir == ([2]f32{0, 0}) {
		p.state = .IDLE
	} else {
		p.state = .MOVE
	}

	// state -> anim name
	switch p.state {
	case .IDLE:
		eng.play(&p.anim, "idle")
	case .MOVE:
		eng.play(&p.anim, "move")
	}

	eng.update_animator(&p.anim, &p.sf, dt)
}

player_draw :: proc(p: ^Player) { 	
	eng.draw_animator(&p.sf, p.anim, p.pos)
}
