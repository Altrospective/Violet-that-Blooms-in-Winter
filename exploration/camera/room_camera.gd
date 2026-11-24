class_name RoomCamera
extends Camera2D
## Smooth-follow camera that stops at room boundaries. Attach as a child of the player;
## the Room calls set_room_bounds() when it loads.

@export var follow_speed: float = 8.0


func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed


## bounds is in room pixels, e.g. Rect2i(0, 0, 960, 540).
func set_room_bounds(bounds: Rect2i) -> void:
	limit_left = bounds.position.x
	limit_top = bounds.position.y
	limit_right = bounds.end.x
	limit_bottom = bounds.end.y
	reset_smoothing()
