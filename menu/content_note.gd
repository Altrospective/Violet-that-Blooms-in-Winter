extends Control
## Short content note shown before the game starts. The wording is a placeholder:
## edit NOTE_TEXT to taste.

@export var scene_title: String = "Content Note"

const NEXT_SCENE: String = "res://home/violet_bedroom.tscn"
const NOTE_TEXT: String = "This game contains themes of bullying, abuse, grief, and withdrawal.\n\nPlease look after yourself while you play, and take a break \n\nwhenever you need one."

var _prompt: Label
var _time: float = 0.0


func _ready() -> void:
	InputActions.ensure_registered()

	var background: ColorRect = ColorRect.new()
	background.color = Color(0.05, 0.05, 0.09)
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var frame: Panel = Panel.new()
	frame.position = Vector2(60, 84)
	frame.size = Vector2(520, 180)
	frame.add_theme_stylebox_override("panel", UiStyle.dark_frame())
	add_child(frame)

	var note: Label = Label.new()
	note.text = NOTE_TEXT
	note.position = Vector2(57, 108)
	note.size = Vector2(464, 112)
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size", 14)
	add_child(note)

	_prompt = Label.new()
	_prompt.text = "Press E, Z, Enter, or Space to continue"
	_prompt.position = Vector2(0, 300)
	_prompt.size = Vector2(640, 20)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 10)
	_prompt.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	add_child(_prompt)


func _process(delta: float) -> void:
	_time += delta
	_prompt.modulate.a = 0.55 + 0.45 * sin(_time * 3.0)


func _unhandled_input(event: InputEvent) -> void:
	if SceneManager.is_busy:
		return
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(InputActions.INTERACT):
		get_viewport().set_input_as_handled()
		SceneManager.change_scene(NEXT_SCENE)
