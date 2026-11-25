extends CanvasLayer
## Scene changes with a fade, scene names, and a small in-game pause menu.
## Registered as the autoload "SceneManager".

signal scene_changed(path: String)

const FADE_TIME: float = 0.5
const TITLE_SECONDS: float = 2.2
const TITLE_SCENE: String = "res://menu/main_menu.tscn"
const RESTART_SCENE: String = "res://menu/content_note.tscn"
const PAUSABLE_SCENES: Array[String] = [
	"res://home/violet_bedroom.tscn",
	"res://school/room_2b_teaser.tscn",
]

var is_busy: bool = false
var _fade: ColorRect
var _title_label: Label
var _title_card: Panel
var _debug_label: Label
var _title_tween: Tween
var _pause_layer: Control
var _resume_button: Button


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_title_card = Panel.new()
	_title_card.position = Vector2(8, 6)
	_title_card.size = Vector2(188, 30)
	_title_card.add_theme_stylebox_override("panel", CozyUITheme.create_objective_tag())
	_title_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_card.modulate.a = 0.0
	add_child(_title_card)

	_title_label = _make_label(12, Vector2(18, 12))
	_title_label.size = Vector2(172, 20)
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.modulate.a = 0.0
	_title_label.add_theme_color_override("font_color", CozyUITheme.COL_INK_TEXT)
	_title_label.add_theme_color_override("font_outline_color", Color.TRANSPARENT)
	_title_label.add_theme_constant_override("outline_size", 0)
	add_child(_title_label)

	_debug_label = _make_label(10, Vector2(8, 338))
	_debug_label.visible = false
	add_child(_debug_label)
	_build_pause_menu()
	_announce_after_startup()


func change_scene(path: String) -> void:
	if is_busy:
		return
	if not ResourceLoader.exists(path):
		push_error("SceneManager: scene not found '%s'" % path)
		return
	is_busy = true
	await _fade_to(1.0)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	_announce_current_scene()
	await _fade_to(0.0)
	is_busy = false
	scene_changed.emit(path)


func _input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.physical_keycode == KEY_F1:
		_debug_label.visible = not _debug_label.visible
	elif key_event.physical_keycode == KEY_ESCAPE and _can_pause():
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()


func _can_pause() -> bool:
	if is_busy or get_tree().current_scene == null:
		return false
	return PAUSABLE_SCENES.has(get_tree().current_scene.scene_file_path)


func _pause_game() -> void:
	_pause_layer.visible = true
	get_tree().paused = true
	_resume_button.grab_focus()


func _resume_game() -> void:
	_pause_layer.visible = false
	get_tree().paused = false


func _restart_demo() -> void:
	_pause_layer.visible = false
	get_tree().paused = false
	GameState.reset()
	change_scene(RESTART_SCENE)


func _return_to_title() -> void:
	_pause_layer.visible = false
	get_tree().paused = false
	change_scene(TITLE_SCENE)


func _build_pause_menu() -> void:
	_pause_layer = Control.new()
	_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_pause_layer.visible = false
	_pause_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_layer.theme = CozyUITheme.build_theme()
	add_child(_pause_layer)
	_pause_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shade: ColorRect = ColorRect.new()
	shade.color = Color(CozyUITheme.COL_DARK_SLATE, 0.82)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_layer.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel: Panel = Panel.new()
	panel.position = Vector2(210, 92)
	panel.size = Vector2(220, 176)
	panel.add_theme_stylebox_override("panel", CozyUITheme.create_dark_box())
	_pause_layer.add_child(panel)

	var title: Label = _make_label(18, Vector2.ZERO)
	title.text = "Paused"
	title.position = Vector2(0, 16)
	title.size = Vector2(220, 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", CozyUITheme.COL_LIGHT_TEXT)
	panel.add_child(title)

	var buttons: VBoxContainer = VBoxContainer.new()
	buttons.position = Vector2(36, 54)
	buttons.size = Vector2(148, 106)
	buttons.add_theme_constant_override("separation", 4)
	panel.add_child(buttons)

	_resume_button = _make_pause_button("Resume")
	_resume_button.pressed.connect(_resume_game)
	buttons.add_child(_resume_button)
	var restart_button: Button = _make_pause_button("Restart demo")
	restart_button.pressed.connect(_restart_demo)
	buttons.add_child(restart_button)
	var title_button: Button = _make_pause_button("Return to title")
	title_button.pressed.connect(_return_to_title)
	buttons.add_child(title_button)


func _make_pause_button(text: String) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(148, 30)
	button.focus_mode = Control.FOCUS_ALL
	return button


func _announce_after_startup() -> void:
	await get_tree().process_frame
	_announce_current_scene()


func _announce_current_scene() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var title: String = scene.name
	var value: Variant = scene.get("scene_title")
	if value != null and str(value) != "":
		title = str(value)
	_title_label.text = title
	_debug_label.text = "%s  [%s]" % [title, scene.scene_file_path]
	if _title_tween != null:
		_title_tween.kill()
	_title_label.modulate.a = 0.0
	_title_card.modulate.a = 0.0
	_title_tween = create_tween()
	_title_tween.tween_property(_title_label, "modulate:a", 1.0, 0.4)
	_title_tween.parallel().tween_property(_title_card, "modulate:a", 1.0, 0.4)
	_title_tween.tween_interval(TITLE_SECONDS)
	_title_tween.tween_property(_title_label, "modulate:a", 0.0, 0.6)
	_title_tween.parallel().tween_property(_title_card, "modulate:a", 0.0, 0.6)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_TIME)
	await tween.finished


func _make_label(font_size: int, pos: Vector2) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", CozyUITheme.COL_LIGHT_TEXT)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 2)
	return label
