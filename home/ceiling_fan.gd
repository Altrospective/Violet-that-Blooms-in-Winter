extends Sprite2D
## A ceiling fan that flickers between two frames so the blades look like they spin.

@export var frame_a: Texture2D
@export var frame_b: Texture2D
@export var interval: float = 0.08

var _time: float = 0.0
var _flip: bool = false


func _process(delta: float) -> void:
	_time += delta
	if _time >= interval:
		_time = 0.0
		_flip = not _flip
		texture = frame_b if _flip else frame_a
