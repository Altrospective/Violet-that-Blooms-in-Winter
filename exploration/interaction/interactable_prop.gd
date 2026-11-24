class_name InteractableProp
extends Interactable
## An interactable with a body that blocks movement. Set sprite_texture to use real art
## (origin at the bottom center); otherwise a placeholder box is drawn.
## body_size is the footprint on the floor (what Violet bumps into).

@export var sprite_texture: Texture2D
@export var placeholder_color: Color = Color(0.45, 0.5, 0.6, 1.0)
@export var placeholder_size: Vector2 = Vector2(24, 18)
@export var body_size: Vector2 = Vector2(16, 8)

@onready var _box: PlaceholderBox = $Box
@onready var _body_shape: CollisionShape2D = $Body/BaseCollision
@onready var _zone_shape: CollisionShape2D = $Zone


func _ready() -> void:
	if sprite_texture != null:
		_box.visible = false
		var sprite: Sprite2D = Sprite2D.new()
		sprite.texture = sprite_texture
		sprite.centered = false
		sprite.offset = Vector2(-sprite_texture.get_width() * 0.5, -float(sprite_texture.get_height()))
		add_child(sprite)
	else:
		_box.color = placeholder_color
		_box.size = placeholder_size

	# Duplicate shapes so instances don't share (and overwrite) each other's size.
	var body_rect: RectangleShape2D = (_body_shape.shape as RectangleShape2D).duplicate()
	body_rect.size = body_size
	_body_shape.shape = body_rect
	_body_shape.position = Vector2(0, -body_size.y * 0.5)

	var zone_rect: RectangleShape2D = (_zone_shape.shape as RectangleShape2D).duplicate()
	zone_rect.size = Vector2(body_size.x + 16.0, 28.0)
	_zone_shape.shape = zone_rect
	_zone_shape.position = Vector2(0, -14.0)
