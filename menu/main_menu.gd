extends Control
## Main menu styled as Violet's perfect dream world (see DreamBackdrop), with
## sketchbook frames and a pencil cursor. New Game goes to the content note.

@export var scene_title: String = "Main Menu"

const NEXT_SCENE: String = "res://menu/content_note.tscn"
const MENU_TOP: float = 232.0
const ROW_HEIGHT: float = 26.0
const INK: Color = Color(0.25, 0.2, 0.35)
const INK_SOFT: Color = Color(0.5, 0.45, 0.6)

# TODO: add "Continue" once saves remember which scene you were in.
var _items: Array[String] = []
var _selected: int = 0
var _labels: Array[Label] = []
var _cursor: TextureRect


func _ready() -> void:
	InputActions.ensure_registered()
	_items = ["New Game"]
	if not OS.has_feature("web"):
		_items.append("Quit")
	add_child(DreamBackdrop.new())
	_build_snow()
	_build_title()
	_build_menu()
	_refresh_menu()


func _unhandled_input(event: InputEvent) -> void:
	if SceneManager.is_busy:
		return
	if event.is_action_pressed(&"ui_down"):
		_selected = (_selected + 1) % _items.size()
		_refresh_menu()
	elif event.is_action_pressed(&"ui_up"):
		_selected = (_selected - 1 + _items.size()) % _items.size()
		_refresh_menu()
	elif event.is_action_pressed(&"ui_accept") or event.is_action_pressed(InputActions.INTERACT):
		_activate()
	else:
		return
	get_viewport().set_input_as_handled()


func _activate() -> void:
	match _items[_selected]:
		"New Game":
			GameState.reset()
			SceneManager.change_scene(NEXT_SCENE)
		"Quit":
			get_tree().quit()


func _refresh_menu() -> void:
	for i: int in range(_labels.size()):
		_labels[i].add_theme_color_override("font_color", INK if i == _selected else INK_SOFT)
	if _cursor != null and not _labels.is_empty():
		_cursor.position = Vector2(244, _labels[_selected].position.y + 2.0)


func _build_title() -> void:
	var banner: Panel = Panel.new()
	banner.position = Vector2(110, 34)
	banner.size = Vector2(420, 66)
	banner.add_theme_stylebox_override("panel", UiStyle.paper_frame())
	add_child(banner)
	add_child(_make_centered_label("Violet that Blooms in Winter", 22, 52.0, INK))
	add_child(_make_centered_label("Lucent Soulworks", 10, 340.0, Color(0.4, 0.35, 0.55)))


func _build_menu() -> void:
	var panel: Panel = Panel.new()
	panel.position = Vector2(232, MENU_TOP - 20.0)
	panel.size = Vector2(176, 44.0 + ROW_HEIGHT * float(_items.size()))
	panel.add_theme_stylebox_override("panel", UiStyle.paper_frame())
	add_child(panel)

	for i: int in range(_items.size()):
		var label: Label = _make_centered_label(_items[i], 16, MENU_TOP + float(i) * ROW_HEIGHT, INK_SOFT)
		add_child(label)
		_labels.append(label)

	var cursor_texture: Texture2D = UiStyle.cursor_texture()
	if cursor_texture != null:
		_cursor = TextureRect.new()
		_cursor.texture = cursor_texture
		_cursor.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_cursor.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_cursor.size = Vector2(24, 24)
		add_child(_cursor)


func _make_centered_label(text: String, font_size: int, y: float, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.position = Vector2(0, y)
	label.size = Vector2(640, font_size + 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _build_snow() -> void:
	var snow: CPUParticles2D = CPUParticles2D.new()
	snow.position = Vector2(320, -8)
	snow.amount = 90
	snow.lifetime = 9.0
	snow.preprocess = 9.0
	snow.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	snow.emission_rect_extents = Vector2(340, 1)
	snow.direction = Vector2(0.15, 1.0)
	snow.spread = 8.0
	snow.gravity = Vector2.ZERO
	snow.initial_velocity_min = 18.0
	snow.initial_velocity_max = 34.0
	snow.scale_amount_min = 1.0
	snow.scale_amount_max = 2.0
	snow.color = Color(1, 1, 1, 0.9)
	add_child(snow)
