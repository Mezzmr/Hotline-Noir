package game

import eng "engine"
import rl "vendor:raylib"

init :: proc() {
	rl.InitWindow(1280, 720, "some game")
	rl.SetTargetFPS(60)
	setup_input()
	setup_player("assets/player.png")
}

update :: proc(dt: f32) {
	eng.input_update()
	dir := eng.get_vector("move_left", "move_right", "move_up", "move_down")
	player_update(dt, &player, dir)
}

draw :: proc() {
	rl.BeginDrawing()
	defer rl.EndDrawing()
	rl.ClearBackground(rl.DARKGRAY)
	player_draw(&player)
}

main :: proc() {
	init()
	defer rl.CloseWindow()
	defer eng.input_destroy()

	for !rl.WindowShouldClose() {
		update(rl.GetFrameTime())
		draw()
	}
}
