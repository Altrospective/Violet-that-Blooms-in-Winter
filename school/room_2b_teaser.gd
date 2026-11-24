extends Node2D
## Demo teaser for Act I: a short, non-interactive look at Room 2-B on a rainy Monday.
## The dialogue is placeholder writing: edit LINES to taste. Ends on the demo end screen.

@export var scene_title: String = "Room 2-B (Act I teaser)"

const NEXT_SCENE: String = "res://menu/demo_end.tscn"
const DIM_SECONDS: float = 16.0

const LINES: Array = [
	{"type": "direction", "text": "Room 2-B. Rain on the windows. Nobody is really listening."},
	{"speaker": "hendra", "portrait": "Tired/Indifferent", "text": "Attendance. Sit down. Quietly."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "Oh, look who finally showed up."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "Still not talking? Great.{pause=0.4} Nobody asked anyway."},
	{"type": "direction", "text": "Everyone is looking. Violet's hands go cold."},
	{"speaker": "violet", "portrait": "Anxious", "text": "...{pause=0.6}"},
	{"speaker": "hendra", "portrait": "Tired/Indifferent", "text": "If you have a problem, write it down and hand in the form."},
	{"type": "direction", "text": "Somewhere under the floor, something begins to crack."},
]

var _dim: ColorRect


func _ready() -> void:
	_build_classroom()

	_dim = ColorRect.new()
	_dim.color = Color(0.1, 0.12, 0.22, 0.0)
	_dim.size = Vector2(640, 360)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)

	await get_tree().create_timer(1.2).timeout
	# The crowd's attention weighs on her: the room slowly darkens while the scene plays.
	var tween: Tween = create_tween()
	tween.tween_property(_dim, "color:a", 0.4, DIM_SECONDS)
	Dialogue.start(LINES)
	await Dialogue.dialogue_finished
	tween.kill()
	SceneManager.change_scene(NEXT_SCENE)


func _build_classroom() -> void:
	_add_sprite("res://assets/backgrounds/classroom.png", Vector2.ZERO, false)
	# Teacher and desk at the front of the room.
	_add_sprite("res://assets/sprites/student_short.png", Vector2(320, 132), true).modulate = Color(0.85, 0.85, 0.95)
	_add_sprite("res://assets/props/teacher_desk.png", Vector2(320, 150), true)
	# Students: a mostly faceless crowd looking out at us. Violet is in the back row,
	# Karin is tinted red.
	for row: int in range(3):
		for col: int in range(6):
			var x: float = 90.0 + float(col) * 88.0
			var y: float = 190.0 + float(row) * 26.0
			if row == 2 and col == 1:
				_add_violet(Vector2(x, y - 2.0))
			else:
				var path: String = "res://assets/sprites/student_long.png" if (row + col) % 2 == 0 else "res://assets/sprites/student_short.png"
				var student: Sprite2D = _add_sprite(path, Vector2(x, y - 2.0), true)
				if row == 1 and col == 4:
					student.modulate = Color(1.0, 0.62, 0.66)
			_add_sprite("res://assets/props/school_desk.png", Vector2(x, y), true)


func _add_violet(feet: Vector2) -> void:
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = load("res://assets/sprites/violet_sheet.png") as Texture2D
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.frame_coords = Vector2i(0, 1)  # facing the board
	sprite.centered = false
	sprite.offset = Vector2(-12, -32)
	sprite.position = feet
	add_child(sprite)


func _add_sprite(path: String, pos: Vector2, feet_origin: bool) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	var texture: Texture2D = load(path) as Texture2D
	sprite.texture = texture
	sprite.centered = false
	sprite.position = pos
	if feet_origin:
		sprite.offset = Vector2(-texture.get_width() * 0.5, -float(texture.get_height()))
	add_child(sprite)
	return sprite
