class_name InputActions
extends RefCounted
## Registers input actions in code so the project works without editor setup.
## Call InputActions.ensure_registered() before reading input (Player does this).

const MOVE_LEFT: StringName = &"move_left"
const MOVE_RIGHT: StringName = &"move_right"
const MOVE_UP: StringName = &"move_up"
const MOVE_DOWN: StringName = &"move_down"
const INTERACT: StringName = &"interact"
const PAUSE: StringName = &"pause"

const DEADZONE: float = 0.2


static func ensure_registered() -> void:
	_bind(MOVE_LEFT, [KEY_A, KEY_LEFT], JOY_AXIS_LEFT_X, -1.0, JOY_BUTTON_DPAD_LEFT)
	_bind(MOVE_RIGHT, [KEY_D, KEY_RIGHT], JOY_AXIS_LEFT_X, 1.0, JOY_BUTTON_DPAD_RIGHT)
	_bind(MOVE_UP, [KEY_W, KEY_UP], JOY_AXIS_LEFT_Y, -1.0, JOY_BUTTON_DPAD_UP)
	_bind(MOVE_DOWN, [KEY_S, KEY_DOWN], JOY_AXIS_LEFT_Y, 1.0, JOY_BUTTON_DPAD_DOWN)
	_bind_interact()
	_bind_pause()


static func _bind(action: StringName, keys: Array, axis: JoyAxis, axis_sign: float, dpad_button: JoyButton) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action, DEADZONE)
	for key: Variant in keys:
		var key_event: InputEventKey = InputEventKey.new()
		key_event.physical_keycode = key as Key
		InputMap.action_add_event(action, key_event)
	var motion: InputEventJoypadMotion = InputEventJoypadMotion.new()
	motion.axis = axis
	motion.axis_value = axis_sign
	InputMap.action_add_event(action, motion)
	var button: InputEventJoypadButton = InputEventJoypadButton.new()
	button.button_index = dpad_button
	InputMap.action_add_event(action, button)


## E, Z, Enter, or Space on keyboard; the A / bottom face button on a gamepad.
static func _bind_interact() -> void:
	if InputMap.has_action(INTERACT):
		return
	InputMap.add_action(INTERACT, DEADZONE)
	for key: Variant in [KEY_E, KEY_Z, KEY_ENTER, KEY_SPACE]:
		var key_event: InputEventKey = InputEventKey.new()
		key_event.physical_keycode = key as Key
		InputMap.action_add_event(INTERACT, key_event)
	var button: InputEventJoypadButton = InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_A
	InputMap.action_add_event(INTERACT, button)


static func _bind_pause() -> void:
	if InputMap.has_action(PAUSE):
		return
	InputMap.add_action(PAUSE)
	var key_event: InputEventKey = InputEventKey.new()
	key_event.physical_keycode = KEY_ESCAPE
	InputMap.action_add_event(PAUSE, key_event)
	var button: InputEventJoypadButton = InputEventJoypadButton.new()
	button.button_index = JOY_BUTTON_START
	InputMap.action_add_event(PAUSE, button)
