class_name Room
extends Node2D
## Base script for an overworld room. The room's top-left corner is at (0, 0).
## Put everything that should be Y-sorted (player, props, NPCs) under a child node
## named "World" with Y Sort Enabled, and keep each node's origin at its feet.

## Shown on screen when the room starts (see SceneManager).
@export var scene_title: String = ""

## Room size in pixels. The camera stops at these edges.
@export var room_size: Vector2i = Vector2i(640, 360)
@export var player_path: NodePath = ^"World/Player"


func _ready() -> void:
	var player: Player = get_node_or_null(player_path) as Player
	if player == null:
		push_error("Room '%s': no Player found at '%s'" % [name, player_path])
		return
	player.camera.set_room_bounds(Rect2i(Vector2i.ZERO, room_size))
