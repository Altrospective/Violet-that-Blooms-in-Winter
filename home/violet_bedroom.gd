extends Room
## Prototype: Violet wakes up at home on a rainy morning. A short narrated wake-up,
## then free movement around the bedroom. The door leads on to the next scene.
## All narration text here is placeholder writing: edit WAKE_LINES and the
## inspect_lines on each object in the scene.

const WAKE_LINES: Array = [
	{"type": "direction", "text": "Rain against the window. Grey light on the ceiling."},
	{"type": "narration", "text": "The alarm has been ringing for a while."},
	{"type": "narration", "text": "...Another Monday."},
]

@onready var _bed_sleeper: Node2D = $World/BedSleeper
@onready var _wake_spot: Marker2D = $WakeSpot


func _ready() -> void:
	super._ready()
	_build_rain()
	var player: Player = get_node(player_path) as Player
	player.hide()
	player.movement_locked = true
	await get_tree().create_timer(1.4).timeout
	Dialogue.start(WAKE_LINES)
	await Dialogue.dialogue_finished
	_bed_sleeper.hide()
	player.global_position = _wake_spot.global_position
	player.show()
	player.movement_locked = false


## Rain streaks inside the louvred window (glass is about 80 wide and 60 tall).
func _build_rain() -> void:
	var rain: CPUParticles2D = CPUParticles2D.new()
	rain.position = Vector2(320, 31)
	rain.amount = 40
	rain.lifetime = 0.45
	rain.preprocess = 0.45
	rain.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	rain.emission_rect_extents = Vector2(38, 1)
	rain.direction = Vector2(0.1, 1.0)
	rain.spread = 3.0
	rain.gravity = Vector2.ZERO
	rain.initial_velocity_min = 100.0
	rain.initial_velocity_max = 120.0
	rain.scale_amount_min = 1.0
	rain.scale_amount_max = 1.5
	rain.color = Color(0.85, 0.9, 1.0, 0.8)
	add_child(rain)
