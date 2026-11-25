class_name Player
extends CharacterBody2D
## Violet in the overworld. Movement is step-and-pause: short bursts of movement with a
## brief stop between each, like a classic pixel game. Her position snaps to whole pixels
## at the end of every step, and she can only change direction between steps.
## Speed scales down as GameState's withdrawal ratio rises.
##
## The node origin is at Violet's feet so Y-sorting uses her feet position.

signal facing_changed(direction: Vector2)

## Pixels per second during a step. One step covers step_speed * step_time pixels (14 by default).
@export var step_speed: float = 100.0
@export var step_time: float = 0.15
@export var pause_time: float = 0.05
## At full withdrawal (all memories shattered) step speed is reduced by this fraction.
@export_range(0.0, 1.0, 0.05) var max_withdrawal_slowdown: float = 0.5

enum Phase { IDLE, STEP, PAUSE }

## Rows in assets/sprites/violet_sheet.png.
const ROW_DOWN: int = 0
const ROW_UP: int = 1
const ROW_LEFT: int = 2
const ROW_RIGHT: int = 3

## Set true during dialogue, transitions, and Inner Winter cutscenes.
var movement_locked: bool = false
## Snapped to the nearest of 8 directions.
var facing: Vector2 = Vector2.DOWN

var _phase: Phase = Phase.IDLE
var _phase_left: float = 0.0
var _step_dir: Vector2 = Vector2.ZERO
var _walk_frame: int = 0
var _speed_scale: float = 1.0

@onready var camera: RoomCamera = $Camera
@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	InputActions.ensure_registered()
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	GameState.withdrawal_changed.connect(_on_withdrawal_changed)
	Dialogue.dialogue_started.connect(_on_dialogue_started)
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_update_speed_scale()
	_apply_frame(0)


func _physics_process(delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO
	if not movement_locked:
		input_dir = Input.get_vector(
			InputActions.MOVE_LEFT, InputActions.MOVE_RIGHT,
			InputActions.MOVE_UP, InputActions.MOVE_DOWN)

	match _phase:
		Phase.IDLE:
			velocity = Vector2.ZERO
			if input_dir != Vector2.ZERO:
				_begin_step(input_dir)
		Phase.STEP:
			velocity = _step_dir * step_speed * _speed_scale
			_phase_left -= delta
			if _phase_left <= 0.0:
				_end_step()
		Phase.PAUSE:
			velocity = Vector2.ZERO
			_phase_left -= delta
			if _phase_left <= 0.0:
				if input_dir != Vector2.ZERO:
					_begin_step(input_dir)
				else:
					_phase = Phase.IDLE
					_apply_frame(0)

	move_and_slide()


func _begin_step(direction: Vector2) -> void:
	_step_dir = direction.normalized()
	_update_facing(_step_dir)
	_walk_frame = (_walk_frame % 3) + 1
	_apply_frame(_walk_frame)
	_phase = Phase.STEP
	_phase_left = step_time


func _end_step() -> void:
	velocity = Vector2.ZERO
	global_position = global_position.round()
	_phase = Phase.PAUSE
	_phase_left = pause_time


func _update_facing(direction: Vector2) -> void:
	var step: float = PI / 4.0
	var snapped_dir: Vector2 = Vector2.from_angle(roundf(direction.angle() / step) * step)
	if not snapped_dir.is_equal_approx(facing):
		facing = snapped_dir
		facing_changed.emit(facing)


func _row_for_facing() -> int:
	if absf(facing.x) >= absf(facing.y):
		return ROW_LEFT if facing.x < 0.0 else ROW_RIGHT
	return ROW_UP if facing.y < 0.0 else ROW_DOWN


func _apply_frame(frame: int) -> void:
	_sprite.frame_coords = Vector2i(frame, _row_for_facing())


func _update_speed_scale() -> void:
	_speed_scale = 1.0 - GameState.get_withdrawal_ratio() * max_withdrawal_slowdown


func _on_withdrawal_changed(_shattered_count: int, _effective_vulnerability: float) -> void:
	_update_speed_scale()


func _on_dialogue_started() -> void:
	movement_locked = true


func _on_dialogue_finished() -> void:
	movement_locked = false
