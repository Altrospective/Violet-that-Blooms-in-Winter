extends CanvasLayer
## Pause controls shared by the playable Act 1 scenes.

const TITLE_SCENE: String = "res://menu/main_menu.tscn"
const RESTART_SCENE: String = "res://menu/content_note.tscn"
const GAMEPLAY_SCENES: Array[String] = [
	"res://home/violet_bedroom.tscn",
	"res://school/room_2b_teaser.tscn",
]

var _overlay: ColorRect
var _resume_button: Button


func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputActions.ensure_registered()
	_build_menu()


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.PAUSE) or SceneManager.is_busy:
		return
	if _overlay.visible:
		_resume()
	elif _is_gameplay_scene():
		_pause()
	else:
		return
	get_viewport().set_input_as_handled()


func _is_gameplay_scene() -> bool:
	var scene: Node = get_tree().current_scene
	return scene != null and GAMEPLAY_SCENES.has(scene.scene_file_path)


func _pause() -> void:
	_overlay.visible = true
	get_tree().paused = true
	_resume_button.grab_focus()


func _resume() -> void:
	_overlay.visible = false
	get_tree().paused = false


func _restart() -> void:
	_resume()
	GameState.reset()
	SceneManager.change_scene(RESTART_SCENE)


func _return_to_title() -> void:
	_resume()
	SceneManager.change_scene(TITLE_SCENE)


func _build_menu() -> void:
	var theme_root: Control = Control.new()
	theme_root.theme = CozyUITheme.build_theme()
	theme_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(theme_root)

	_overlay = ColorRect.new()
	_overlay.color = Color(CozyUITheme.COL_DARK_SLATE, 0.82)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.visible = false
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme_root.add_child(_overlay)

	var panel: Panel = Panel.new()
	panel.position = Vector2(188, 74)
	panel.size = Vector2(264, 212)
	panel.add_theme_stylebox_override("panel", CozyUITheme.create_dark_box())
	_overlay.add_child(panel)

	var heading: Label = Label.new()
	heading.text = "Paused"
	heading.position = Vector2(0, 20)
	heading.size = Vector2(264, 28)
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 20)
	heading.add_theme_color_override("font_color", CozyUITheme.COL_LIGHT_TEXT)
	panel.add_child(heading)

	_resume_button = _make_button("Resume", 64)
	_resume_button.pressed.connect(_resume)
	panel.add_child(_resume_button)

	var restart_button: Button = _make_button("Restart demo", 106)
	restart_button.pressed.connect(_restart)
	panel.add_child(restart_button)

	var title_button: Button = _make_button("Return to title", 148)
	title_button.pressed.connect(_return_to_title)
	panel.add_child(title_button)


func _make_button(text: String, y: float) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.position = Vector2(32, y)
	button.size = Vector2(200, 32)
	return button
