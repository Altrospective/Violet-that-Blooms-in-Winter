extends CanvasLayer
## Small, keyboard-first guidance for the playable Act 1 room.

@export_multiline var objective_text: String = "Look around, then head to school."
@export var player_path: NodePath = ^"../World/Player"

var _root: Control
var _prompt: Label


func _ready() -> void:
	layer = 5
	var player: Player = get_node_or_null(player_path) as Player
	if player == null:
		push_error("GameHud: no Player found at '%s'" % player_path)
		return
	var interactor: Interactor = player.get_node_or_null("Interactor") as Interactor
	if interactor == null:
		push_error("GameHud: Player has no Interactor")
		return
	interactor.prompt_changed.connect(_on_prompt_changed)
	Dialogue.dialogue_started.connect(_on_dialogue_started)
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_build_ui()


func _build_ui() -> void:
	_root = Control.new()
	_root.theme = CozyUITheme.build_theme()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var objective_panel: Panel = Panel.new()
	objective_panel.position = Vector2(12, 30)
	objective_panel.size = Vector2(300, 30)
	objective_panel.add_theme_stylebox_override("panel", CozyUITheme.create_objective_tag())
	objective_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(objective_panel)

	var objective: Label = Label.new()
	objective.text = "Objective: %s" % objective_text
	objective.position = Vector2(12, 0)
	objective.size = Vector2(278, 30)
	objective.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	objective.autowrap_mode = TextServer.AUTOWRAP_OFF
	objective.mouse_filter = Control.MOUSE_FILTER_IGNORE
	objective.add_theme_font_size_override("font_size", 10)
	objective.add_theme_color_override("font_color", CozyUITheme.COL_INK_TEXT)
	objective_panel.add_child(objective)

	_prompt = Label.new()
	_prompt.position = Vector2(0, 222)
	_prompt.size = Vector2(640, 18)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.add_theme_font_size_override("font_size", 10)
	_prompt.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78))
	_prompt.visible = false
	_root.add_child(_prompt)

	var controls_panel: Panel = Panel.new()
	controls_panel.position = Vector2(96, 330)
	controls_panel.size = Vector2(448, 22)
	var pill: StyleBoxFlat = StyleBoxFlat.new()
	pill.bg_color = Color(CozyUITheme.COL_DARK_SLATE, 0.84)
	pill.border_color = Color(CozyUITheme.COL_SWEATER_TAUPE, 0.7)
	pill.set_border_width_all(1)
	pill.set_corner_radius_all(0)
	controls_panel.add_theme_stylebox_override("panel", pill)
	controls_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(controls_panel)

	var controls: Label = Label.new()
	controls.text = "Move: WASD / arrows   Interact: E / Z / Enter / Space   Pause: Esc"
	controls.position = Vector2(8, 0)
	controls.size = Vector2(432, 22)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	controls.mouse_filter = Control.MOUSE_FILTER_IGNORE
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", CozyUITheme.COL_LIGHT_TEXT)
	controls_panel.add_child(controls)


func _on_prompt_changed(prompt: String) -> void:
	_prompt.text = prompt
	_prompt.visible = not prompt.is_empty() and not Dialogue.is_active


func _on_dialogue_started() -> void:
	_prompt.visible = false


func _on_dialogue_finished() -> void:
	_prompt.visible = not _prompt.text.is_empty()
