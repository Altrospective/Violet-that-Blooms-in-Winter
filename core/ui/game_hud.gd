extends CanvasLayer
## Small, keyboard-first guidance for the playable Act 1 room.

@export_multiline var objective_text: String = "Look around, then head to school."
@export var player_path: NodePath = ^"../World/Player"

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
	var objective_panel: Panel = Panel.new()
	objective_panel.position = Vector2(12, 30)
	objective_panel.size = Vector2(300, 42)
	objective_panel.add_theme_stylebox_override("panel", UiStyle.paper_frame())
	add_child(objective_panel)

	var objective: Label = Label.new()
	objective.text = "Objective: %s" % objective_text
	objective.position = Vector2(8, 4)
	objective.size = Vector2(284, 34)
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.add_theme_font_size_override("font_size", 10)
	objective.add_theme_color_override("font_color", Color(0.25, 0.2, 0.35))
	objective_panel.add_child(objective)

	_prompt = Label.new()
	_prompt.position = Vector2(0, 222)
	_prompt.size = Vector2(640, 18)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_size_override("font_size", 10)
	_prompt.add_theme_color_override("font_color", Color(0.95, 0.9, 0.78))
	_prompt.visible = false
	add_child(_prompt)

	var controls: Label = Label.new()
	controls.text = "Move: WASD / arrows   Interact: E / Z / Enter / Space   Pause: Esc"
	controls.position = Vector2(0, 340)
	controls.size = Vector2(640, 16)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls.add_theme_font_size_override("font_size", 8)
	controls.add_theme_color_override("font_color", Color(0.86, 0.85, 0.92))
	add_child(controls)


func _on_prompt_changed(prompt: String) -> void:
	_prompt.text = prompt
	_prompt.visible = not prompt.is_empty() and not Dialogue.is_active


func _on_dialogue_started() -> void:
	_prompt.visible = false


func _on_dialogue_finished() -> void:
	_prompt.visible = not _prompt.text.is_empty()
