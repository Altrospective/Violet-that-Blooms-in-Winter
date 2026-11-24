extends Node2D
## Chapter One: Room 2-B, the stairwell, and Violet's Monday evening.

@export var scene_title: String = "Room 2-B — Monday"

const NEXT_SCENE: String = "res://menu/demo_end.tscn"
const DREAM_TEXTURE_PATH: String = "res://assets/backgrounds/menu_dream.png"
const BEDROOM_TEXTURE_PATH: String = "res://assets/backgrounds/bedroom.png"
const DESK_TEXTURE_PATH: String = "res://assets/props/desk.png"
const STUDENT_TEXTURE_PATH: String = "res://assets/sprites/student_short.png"
const VIOLET_TEXTURE_PATH: String = "res://assets/sprites/violet_sheet.png"

const CLASSROOM_LINES: Array = [
	{"type": "direction", "text": "The flag ceremony is cancelled. Rain fogs the windows of Room 2-B."},
	{"type": "narration", "text": "Violet takes the back desk by the wall. Bag under the chair. Pencil case on the corner. Hands in her lap."},
	{"speaker": "hendra", "portrait": "Tired/Indifferent", "text": "Attendance. Sit down. Quietly."},
	{"type": "narration", "text": "When he reaches Violet's name, she answers: hadir. Mr. Hendra marks the folder without looking up."},
	{"type": "direction", "text": "The door bangs open. Karin arrives late, with two friends behind her."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "Pak, we were at the canteen. It's raining. It's rude to be on time when it's raining."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "Oh, look. Who finally showed up."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "Hey, Violet. Still not talking? Great. Nobody asked anyway."},
	{"type": "direction", "text": "Karin knocks the pencil case from the desk. Pencils scatter under the chairs."},
	{"type": "narration", "text": "The room keeps making noise, but Violet feels it move to the other side of glass. Faces turn toward her, pale and empty."},
	{"speaker": "hendra", "portrait": "Tired/Indifferent", "text": "Karin. Sit down."},
	{"speaker": "karin", "portrait": "Smirk/Mocking", "text": "I am sitting down, Pak."},
	{"type": "narration", "text": "Violet gathers her pencils one at a time. A hand appears beside hers, then is gone. One pencil rests by her shoe."},
	{"type": "direction", "text": "Under the floor, something creaks like ice on a still night."},
]

const MEMORY_LINES: Array = [
	{"type": "direction", "text": "The floor lets go. Violet stands on a frozen lake beneath a shell-pink sky."},
	{"type": "narration", "text": "For a moment, nobody is looking. Her hands grow warm. Beneath the ice: a paper boat, a bus ticket, a lit kitchen window, a pair of small hands."},
	{"type": "narration", "text": "Under her palm is a rainy bus window. Her mother's hand wraps around hers, thumb moving in a slow circle."},
	{"speaker": "violet", "portrait": "Anxious", "text": "No. No, no, wait."},
	{"type": "direction", "text": "A crack runs out from her palm. The bus window breaks and the memory sinks into the dark."},
	{"type": "narration", "text": "Her palm remembers the warmth. It no longer remembers whose hand it was."},
]

const STAIRWELL_INTRO_LINES: Array = [
	{"type": "narration", "text": "The classroom returns. Violet tries to remember what Mama used to hum on the bus. There is only an empty place where the song was."},
	{"type": "narration", "text": "At break, the canteen is too loud. Violet goes to the stairwell window and watches rain cross the quad."},
	{"type": "direction", "text": "Someone stops three steps down, leaving room between them."},
]

const REY_LINES: Array = [
	{"speaker": "rey", "portrait": "Confused/Awkward", "text": "Hi. Violet, right? Sorry. You probably want to be left alone."},
	{"type": "narration", "text": "Violet says nothing."},
	{"speaker": "rey", "portrait": "Concerned", "text": "I saw your sketchbook on Friday. The window drawing, with the rain. It was really good. I just wanted you to know someone noticed."},
	{"type": "narration", "text": "The words to tell him not to look are ready. Then Violet remembers the hand beside her in the classroom."},
	{"speaker": "violet", "portrait": "Neutral/Quiet", "text": "...Was it you? The pencil."},
	{"speaker": "rey", "portrait": "Confused/Awkward", "text": "Yeah. It rolled under my chair. I didn't want to make it a thing."},
	{"type": "narration", "text": "Violet nods. It costs more than it should."},
	{"speaker": "rey", "portrait": "Warm Smile", "text": "Okay. That's all. See you tomorrow?"},
	{"type": "narration", "text": "She doesn't answer. She doesn't leave either. Rey gives a small wave and goes down the stairs."},
]

const EVENING_LINES: Array = [
	{"type": "direction", "text": "That evening. Rain at the window. The fan turns above Violet's desk."},
	{"type": "narration", "text": "For the first time since Friday, Violet opens the sketchbook. The rain-window drawing waits on the first page."},
	{"type": "narration", "text": "On a clean page, she draws a hand resting on another hand on a bus seat. The drawing is not quite right. Something is missing."},
	{"type": "narration", "text": "Underneath, she writes: Monday. Someone looked."},
	{"type": "direction", "text": "She closes the book. The rain goes on."},
]

var _classroom_root: Node2D
var _dream_root: Node2D
var _stairwell_root: Node2D
var _evening_root: Node2D
var _dim: ColorRect


func _ready() -> void:
	InputActions.ensure_registered()
	_build_classroom()
	_build_dream()
	_build_stairwell()
	_build_evening()
	_build_transition_overlay()

	await get_tree().create_timer(0.7).timeout
	await _play_lines(CLASSROOM_LINES)
	await _show_only(_dream_root)
	await _play_lines(MEMORY_LINES)
	GameState.shatter_memory(&"monday_bus_hand")
	await _show_only(_classroom_root)
	await _play_lines(STAIRWELL_INTRO_LINES)
	await _show_only(_stairwell_root)
	await _play_lines(REY_LINES)
	await _show_only(_evening_root)
	await _play_lines(EVENING_LINES)
	SceneManager.change_scene(NEXT_SCENE)


func _play_lines(lines: Array) -> void:
	Dialogue.start(lines)
	await Dialogue.dialogue_finished


func _show_only(target: Node2D) -> void:
	await _fade_to(1.0)
	_classroom_root.visible = target == _classroom_root
	_dream_root.visible = target == _dream_root
	_stairwell_root.visible = target == _stairwell_root
	_evening_root.visible = target == _evening_root
	await _fade_to(0.0)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_dim, "color:a", alpha, 0.45)
	await tween.finished


func _build_transition_overlay() -> void:
	_dim = ColorRect.new()
	_dim.color = Color(0.03, 0.04, 0.09, 0.0)
	_dim.size = Vector2(640, 360)
	_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_dim)


func _build_classroom() -> void:
	_classroom_root = Node2D.new()
	add_child(_classroom_root)
	_add_sprite(_classroom_root, "res://assets/backgrounds/classroom.png", Vector2.ZERO, false)
	_add_sprite(_classroom_root, STUDENT_TEXTURE_PATH, Vector2(320, 132), true).modulate = Color(0.85, 0.85, 0.95)
	_add_sprite(_classroom_root, "res://assets/props/teacher_desk.png", Vector2(320, 150), true)
	for row: int in range(3):
		for col: int in range(6):
			var x: float = 90.0 + float(col) * 88.0
			var y: float = 190.0 + float(row) * 26.0
			if row == 2 and col == 1:
				_add_violet(_classroom_root, Vector2(x, y - 2.0), 1)
			else:
				var path: String = "res://assets/sprites/student_long.png" if (row + col) % 2 == 0 else STUDENT_TEXTURE_PATH
				var student: Sprite2D = _add_sprite(_classroom_root, path, Vector2(x, y - 2.0), true)
				if row == 1 and col == 4:
					student.modulate = Color(1.0, 0.62, 0.66)
			_add_sprite(_classroom_root, "res://assets/props/school_desk.png", Vector2(x, y), true)


func _build_dream() -> void:
	_dream_root = Node2D.new()
	_dream_root.visible = false
	add_child(_dream_root)
	_add_sprite(_dream_root, DREAM_TEXTURE_PATH, Vector2.ZERO, false)


func _build_stairwell() -> void:
	_stairwell_root = Node2D.new()
	_stairwell_root.visible = false
	add_child(_stairwell_root)
	# TODO: replace this shape-based stairwell with final environment art.
	_add_rect(_stairwell_root, Vector2.ZERO, Vector2(640, 360), Color(0.33, 0.38, 0.43))
	_add_rect(_stairwell_root, Vector2(414, 34), Vector2(172, 132), Color(0.72, 0.79, 0.82))
	_add_rect(_stairwell_root, Vector2(422, 42), Vector2(156, 116), Color(0.56, 0.67, 0.73))
	for slat: int in range(7):
		_add_rect(_stairwell_root, Vector2(422, 48 + slat * 16), Vector2(156, 3), Color(0.8, 0.84, 0.84))
	_add_rect(_stairwell_root, Vector2(0, 304), Vector2(640, 56), Color(0.42, 0.43, 0.45))
	for step: int in range(7):
		_add_rect(_stairwell_root, Vector2(24 + step * 73, 280 - step * 27), Vector2(80, 28), Color(0.49, 0.51, 0.52))
	_add_line(_stairwell_root, PackedVector2Array([Vector2(12, 118), Vector2(206, 118), Vector2(334, 250), Vector2(590, 250)]), Color(0.75, 0.77, 0.76), 3.0)
	_add_violet(_stairwell_root, Vector2(320, 248), 0)
	_add_sprite(_stairwell_root, STUDENT_TEXTURE_PATH, Vector2(396, 222), true).modulate = Color(0.91, 0.78, 0.6)


func _build_evening() -> void:
	_evening_root = Node2D.new()
	_evening_root.visible = false
	add_child(_evening_root)
	_add_sprite(_evening_root, BEDROOM_TEXTURE_PATH, Vector2.ZERO, false)
	_add_rect(_evening_root, Vector2.ZERO, Vector2(640, 360), Color(0.12, 0.12, 0.22, 0.4))
	_add_sprite(_evening_root, DESK_TEXTURE_PATH, Vector2(545, 138), true)
	# TODO: replace the paper and line drawing with the finished sketchbook art.
	_add_rect(_evening_root, Vector2(531, 112), Vector2(24, 30), Color(0.91, 0.86, 0.73))
	_add_line(_evening_root, PackedVector2Array([Vector2(536, 121), Vector2(544, 116), Vector2(550, 124), Vector2(544, 132)]), Color(0.31, 0.28, 0.4), 1.0)
	_add_violet(_evening_root, Vector2(492, 183), 2)


func _add_rect(parent: Node2D, pos: Vector2, size: Vector2, color: Color) -> ColorRect:
	var rect: ColorRect = ColorRect.new()
	rect.position = pos
	rect.size = size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	return rect


func _add_line(parent: Node2D, points: PackedVector2Array, color: Color, width: float) -> Line2D:
	var line: Line2D = Line2D.new()
	line.points = points
	line.default_color = color
	line.width = width
	line.antialiased = false
	parent.add_child(line)
	return line


func _add_violet(parent: Node2D, feet: Vector2, row: int) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	var texture: Texture2D = load(VIOLET_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_error("Room2B: missing Violet sprite '%s'" % VIOLET_TEXTURE_PATH)
		return sprite
	sprite.texture = texture
	sprite.hframes = 3
	sprite.vframes = 4
	sprite.frame_coords = Vector2i(0, row)
	sprite.centered = false
	sprite.offset = Vector2(-12, -32)
	sprite.position = feet
	parent.add_child(sprite)
	return sprite


func _add_sprite(parent: Node2D, path: String, pos: Vector2, feet_origin: bool) -> Sprite2D:
	var sprite: Sprite2D = Sprite2D.new()
	var texture: Texture2D = load(path) as Texture2D
	if texture == null:
		push_error("Room2B: missing scene art '%s'" % path)
		return sprite
	sprite.texture = texture
	sprite.centered = false
	sprite.position = pos
	if feet_origin:
		sprite.offset = Vector2(-texture.get_width() * 0.5, -float(texture.get_height()))
	parent.add_child(sprite)
	return sprite
