extends Node
## Debug only. Press 1 to shatter the next memory, 2 to reset the story state.
## Watch Violet slow down as the withdrawal ratio rises. Remove before shipping.

var _next_id: int = 0


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	match key_event.physical_keycode:
		KEY_1:
			GameState.shatter_memory(StringName("debug_%d" % _next_id))
			_next_id += 1
			print("shattered %d, withdrawal ratio %.2f" % [
				GameState.get_shattered_count(), GameState.get_withdrawal_ratio()])
		KEY_2:
			GameState.reset()
			_next_id = 0
			print("state reset")
