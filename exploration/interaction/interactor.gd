class_name Interactor
extends Area2D
## Sits in front of Violet, following her 8-direction facing. Press interact to use the
## nearest Interactable overlapping this area.

@export var reach: float = 14.0
@export var center_offset: Vector2 = Vector2(0, -8)

@onready var _player: Player = get_parent() as Player


func _ready() -> void:
	InputActions.ensure_registered()
	_player.facing_changed.connect(_on_facing_changed)
	_place(_player.facing)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(InputActions.INTERACT):
		return
	if Dialogue.is_active or _player.movement_locked or SceneManager.is_busy:
		return
	var target: Interactable = _nearest_interactable()
	if target != null:
		get_viewport().set_input_as_handled()
		target.interact(_player)


func _nearest_interactable() -> Interactable:
	var best: Interactable = null
	var best_distance: float = INF
	for area: Area2D in get_overlapping_areas():
		var candidate: Interactable = area as Interactable
		if candidate == null:
			continue
		var distance: float = _player.global_position.distance_squared_to(candidate.global_position)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return best


func _place(direction: Vector2) -> void:
	position = center_offset + direction * reach


func _on_facing_changed(direction: Vector2) -> void:
	_place(direction)
