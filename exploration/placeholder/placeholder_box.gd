@tool
class_name PlaceholderBox
extends Node2D
## Temporary stand-in art: a filled box whose bottom-center sits on this node's origin
## (the feet). Replace with real sprites later.

@export var size: Vector2 = Vector2(12, 20):
	set(value):
		size = value
		queue_redraw()

@export var color: Color = Color(0.55, 0.45, 0.75, 1.0):
	set(value):
		color = value
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2(-size.x * 0.5, -size.y), size), color)
