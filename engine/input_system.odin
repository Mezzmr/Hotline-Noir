package engine

import rl "vendor:raylib"

// Event kinds. Tagged union = one value holds exactly one of these types,
// `switch v in e` picks which.
Key_Event :: struct {
	key: rl.KeyboardKey,
}
Mouse_Event :: struct {
	button: rl.MouseButton,
}
Pad_Button_Event :: struct {
	button: rl.GamepadButton,
}
Pad_Axis_Event :: struct {
	axis: rl.GamepadAxis,
	sign: f32,
} // sign: which stick direction counts (-1 or 1)

Input_Event :: union {
	Key_Event,
	Mouse_Event,
	Pad_Button_Event,
	Pad_Axis_Event,
}

Action :: struct {
	events:   [dynamic]Input_Event,
	deadzone: f32, // strength below this = not down (ignores stick drift)

	// per-frame state, filled by input_update
	strength: f32, // 0..1, analog value
	down:     bool,
	pressed:  bool, // went down this frame
	released: bool, // went up this frame
}

Input_Map :: struct {
	actions: map[string]Action,
	gamepad: i32, // which pad index to read
}

input_map: Input_Map

// ---------- setup ----------

input_add_action :: proc(name: string, deadzone: f32 = 0.5) {
	if name not_in input_map.actions {
		input_map.actions[name] = Action {
			deadzone = deadzone,
		}
	}
}

input_bind :: proc(name: string, e: Input_Event) {
	if a, ok := &input_map.actions[name]; ok {
		append(&a.events, e)
	}
}

input_clear :: proc(name: string) {
	if a, ok := &input_map.actions[name]; ok {
		clear(&a.events)
	}
}

input_destroy :: proc() {
	for _, &a in input_map.actions do delete(a.events)
	delete(input_map.actions)
}

// ---------- per-frame update ----------

event_strength :: proc(e: Input_Event, pad: i32) -> f32 {
	switch v in e {
	case Key_Event:
		return 1 if rl.IsKeyDown(v.key) else 0
	case Mouse_Event:
		return 1 if rl.IsMouseButtonDown(v.button) else 0
	case Pad_Button_Event:
		return 1 if rl.IsGamepadButtonDown(pad, v.button) else 0
	case Pad_Axis_Event:
		if !rl.IsGamepadAvailable(pad) do return 0
		raw := rl.GetGamepadAxisMovement(pad, v.axis)
		// raylib triggers rest at -1, go to +1. Remap to 0..1.
		if v.axis == .LEFT_TRIGGER || v.axis == .RIGHT_TRIGGER {
			raw = (raw + 1) * 0.5
		}
		return max(raw * v.sign, 0)
	}
	return 0
}

// Call ONCE per frame, top of game loop, before game logic.
input_update :: proc() {
	for _, &a in input_map.actions {
		was_down := a.down

		s: f32
		for e in a.events {
			s = max(s, event_strength(e, input_map.gamepad))
		}

		a.strength = s
		a.down = s > a.deadzone
		a.pressed = a.down && !was_down // edge detection: compare to last frame
		a.released = !a.down && was_down
	}
}

// ---------- queries ----------

is_action_down :: proc(name: string) -> bool {
	a, ok := input_map.actions[name]
	return ok && a.down
}

is_action_pressed :: proc(name: string) -> bool {
	a, ok := input_map.actions[name]
	return ok && a.pressed
}

is_action_released :: proc(name: string) -> bool {
	a, ok := input_map.actions[name]
	return ok && a.released
}

action_strength :: proc(name: string) -> f32 {
	a, ok := input_map.actions[name]
	return a.strength if ok else 0
}

// -1..1 from two actions
get_axis :: proc(neg, pos: string) -> f32 {
	return action_strength(pos) - action_strength(neg)
}

// 2D move vector, length capped at 1 (no fast diagonals)
get_vector :: proc(neg_x, pos_x, neg_y, pos_y: string, deadzone: f32 = 0.2) -> [2]f32 {
	v := [2]f32{get_axis(neg_x, pos_x), get_axis(neg_y, pos_y)}
	l := rl.Vector2Length(v)
	if l < deadzone do return {}
	if l > 1 do v /= l
	return v
}
