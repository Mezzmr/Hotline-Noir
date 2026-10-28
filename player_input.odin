package game

import eng "engine"

setup_input :: proc() {
	eng.input_add_action("move_left")
	eng.input_add_action("move_right")
	eng.input_add_action("move_up")
	eng.input_add_action("move_down")

	eng.input_bind("move_left", eng.Key_Event{.A})
	eng.input_bind("move_left", eng.Key_Event{.LEFT})
	eng.input_bind("move_left", eng.Pad_Axis_Event{.LEFT_X, -1})
	eng.input_bind("move_right", eng.Key_Event{.D})
	eng.input_bind("move_right", eng.Key_Event{.RIGHT})
	eng.input_bind("move_right", eng.Pad_Axis_Event{.LEFT_X, 1})
	eng.input_bind("move_up", eng.Key_Event{.W})
	eng.input_bind("move_up", eng.Key_Event{.UP})
	eng.input_bind("move_up", eng.Pad_Axis_Event{.LEFT_Y, -1})
	eng.input_bind("move_down", eng.Key_Event{.S})
	eng.input_bind("move_down", eng.Key_Event{.DOWN})
	eng.input_bind("move_down", eng.Pad_Axis_Event{.LEFT_Y, 1})
}
