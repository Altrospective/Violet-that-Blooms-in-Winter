extends CanvasLayer
## Scene changes with a fade, plus scene names so you always know where you are.
## Registered as the autoload "SceneManager".
##
## Every scene can set a `scene_title` (export or plain var on its root script).
## The title appears briefly in the top-left whenever a scene starts. Press F1 to
## keep a debug label visible in the bottom-left with the title and file path.

signal scene_changed(path: String)

const FADE_TIME: float = 0.5
const TITLE_SECONDS: float = 2.2

var is_busy: bool = false

var _fade: ColorRect
var _title_label: Label
var _debug_label: Label
var _title_tween: Tween


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS

	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_title_label = _make_label(14, Vector2(12, 10))
	_title_label.modulate.a = 0.0
	add_child(_title_label)

	_debug_label = _make_label(10, Vector2(8, 338))
	_debug_label.visible = false
	add_child(_debug_label)

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
	_title_tween = create_tween()
	_title_tween.tween_property(_title_label, "modulate:a", 1.0, 0.4)
	_title_tween.tween_interval(TITLE_SECONDS)
	_title_tween.tween_property(_title_label, "modulate:a", 0.0, 0.6)


func _fade_to(alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_TIME)
	await tween.finished


func _make_label(font_size: int, pos: Vector2) -> Label:
	var label: Label = Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 3)
	return label
