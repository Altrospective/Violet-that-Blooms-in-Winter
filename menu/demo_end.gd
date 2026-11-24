extends Control
## End of the itch.io demo. Press a button to return to the title.

@export var scene_title: String = "Demo End"

const TITLE_SCENE: String = "res://menu/main_menu.tscn"

var _prompt: Label
var _time: float = 0.0


func _ready() -> void:
	InputActions.ensure_registered()

	var background: ColorRect = ColorRect.new()
	background.color = Color(0.1, 0.08, 0.18)
	add_child(background)
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var frame: Panel = Panel.new()
	frame.position = Vector2(140, 76)
	frame.size = Vector2(360, 178)
	frame.add_theme_stylebox_override("panel", UiStyle.dark_frame())
	add_child(frame)

	add_child(_make_label("Demo Complete", 22, 100.0, Color(0.85, 0.8, 0.95)))
	add_child(_make_label("Chapter One: Frost on the Glass", 12, 146.0, Color(0.8, 0.8, 0.9)))
	add_child(_make_label("Thank you for playing.", 12, 168.0, Color(0.8, 0.8, 0.9)))
	add_child(_make_label("This demo ends here.", 10, 200.0, Color(0.7, 0.62, 0.85)))
	add_child(_make_label("Lucent Soulworks", 10, 218.0, Color(0.6, 0.6, 0.75)))

	_prompt = _make_label("Press E, Z, Enter, or Space to return to the title", 10, 300.0, Color(0.7, 0.7, 0.8))
	add_child(_prompt)


func _process(delta: float) -> void:
	_time += delta
	_prompt.modulate.a = 0.55 + 0.45 * sin(_time * 3.0)


func _unhandled_input(event: InputEvent) -> void:
	if SceneManager.is_busy:
		return
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(InputActions.INTERACT):
		get_viewport().set_input_as_handled()
		SceneManager.change_scene(TITLE_SCENE)


func _make_label(text: String, font_size: int, y: float, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(0, y)
	label.size = Vector2(640, font_size + 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label
