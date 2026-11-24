class_name DreamBackdrop
extends Node2D
## Violet's "perfect" dream world, drawn in code for the main menu: pastel banded sky,
## a pale doubled sun, a frozen lake with cracks, one blooming violet, and faint
## withered violets beneath the ice. It is meant to look calm and just slightly wrong.

const W: float = 640.0
const H: float = 360.0
const HORIZON: float = 200.0
const BAND: float = 4.0

const BG_PATH: String = "res://assets/backgrounds/menu_dream.png"
const FLOWER_PATH: String = "res://assets/sprites/violet_flower.png"

var _time: float = 0.0
var _bg: Texture2D
var _flower: Texture2D


func _ready() -> void:
	if ResourceLoader.exists(BG_PATH):
		_bg = load(BG_PATH) as Texture2D
	if ResourceLoader.exists(FLOWER_PATH):
		_flower = load(FLOWER_PATH) as Texture2D


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	if _bg != null:
		draw_texture(_bg, Vector2.ZERO)
		_draw_pixel_sun()
		_draw_shimmer()
		_draw_flower()
		return
	_draw_sky()
	_draw_sun()
	_draw_hills()
	_draw_lake()
	_draw_withered_violets()
	_draw_violet(Vector2(150, 276), 1.6)


func _draw_sky() -> void:
	var top: Color = Color(0.72, 0.66, 0.9)
	var bottom: Color = Color(1.0, 0.86, 0.92)
	var y: float = 0.0
	while y < HORIZON:
		draw_rect(Rect2(0, y, W, BAND), top.lerp(bottom, y / HORIZON))
		y += BAND


func _draw_sun() -> void:
	var center: Vector2 = Vector2(470, 128)
	var pulse: float = 1.0 + sin(_time * 0.8) * 0.03
	draw_circle(center, 34.0 * pulse, Color(1, 0.97, 0.9, 0.35))
	draw_circle(center, 24.0 * pulse, Color(1, 0.98, 0.93, 0.95))
	# A second, fainter sun that doesn't quite line up.
	draw_circle(center + Vector2(14, -6), 24.0 * pulse, Color(1, 1, 1, 0.18))


func _draw_hills() -> void:
	var points: PackedVector2Array = PackedVector2Array([
		Vector2(0, HORIZON), Vector2(0, 176), Vector2(90, 164), Vector2(180, 182),
		Vector2(260, 170), Vector2(360, 186), Vector2(450, 168), Vector2(540, 180),
		Vector2(W, 172), Vector2(W, HORIZON),
	])
	draw_colored_polygon(points, Color(0.78, 0.7, 0.88))


func _draw_lake() -> void:
	var top: Color = Color(0.88, 0.93, 0.98)
	var bottom: Color = Color(0.66, 0.78, 0.9)
	var y: float = HORIZON
	while y < H:
		draw_rect(Rect2(0, y, W, BAND), top.lerp(bottom, (y - HORIZON) / (H - HORIZON)))
		y += BAND

	# Sun reflection shimmer.
	for i: int in range(10):
		var width: float = 26.0 - float(i) * 1.8
		var offset: float = sin(_time * 1.2 + float(i)) * 3.0
		draw_rect(Rect2(470.0 - width * 0.5 + offset, HORIZON + 6.0 + float(i) * 14.0, width, 2.0), Color(1, 1, 1, 0.5))

	# Cracks in the ice.
	var crack_color: Color = Color(1, 1, 1, 0.4)
	draw_polyline(PackedVector2Array([Vector2(60, 320), Vector2(100, 300), Vector2(130, 308), Vector2(180, 284)]), crack_color, 1.0)
	draw_polyline(PackedVector2Array([Vector2(420, 340), Vector2(470, 316), Vector2(520, 324), Vector2(580, 296)]), crack_color, 1.0)
	draw_polyline(PackedVector2Array([Vector2(300, 352), Vector2(320, 322), Vector2(310, 298)]), crack_color, 1.0)


func _draw_withered_violets() -> void:
	var color: Color = Color(0.35, 0.25, 0.5, 0.35)
	for p: Vector2 in [Vector2(120, 336), Vector2(250, 314), Vector2(380, 338), Vector2(520, 310), Vector2(90, 292)]:
		draw_circle(p, 3.0, color)
		draw_line(p, p + Vector2(0, -8), color, 1.0)


func _draw_violet(base: Vector2, s: float) -> void:
	var sway: float = sin(_time * 1.1) * 1.0
	var top: Vector2 = base + Vector2(sway, -16.0 * s)
	draw_circle(top, 14.0 * s, Color(0.7, 0.5, 0.95, 0.15 + 0.05 * sin(_time * 1.5)))
	draw_line(base, top, Color(0.4, 0.6, 0.4), 2.0)
	draw_colored_polygon(PackedVector2Array([base + Vector2(0, -5.0 * s), base + Vector2(9.0 * s, -10.0 * s), base + Vector2(2.0 * s, -11.0 * s)]), Color(0.45, 0.65, 0.45))
	for i: int in range(5):
		var angle: float = TAU * float(i) / 5.0 - PI * 0.5
		draw_circle(top + Vector2.from_angle(angle) * 4.0 * s, 4.0 * s, Color(0.58, 0.38, 0.85))
	draw_circle(top, 2.0 * s, Color(1.0, 0.85, 0.4))


# ---------- pixel-art version (used when the textures exist) ----------

func _pixel_disc(center: Vector2, radius: int, color: Color) -> void:
	for dy: int in range(-radius, radius + 1):
		var half: int = int(sqrt(float(radius * radius - dy * dy)))
		draw_rect(Rect2(center.x - half, center.y + dy, half * 2 + 1, 1), color)


func _draw_pixel_sun() -> void:
	var center: Vector2 = Vector2(470, 128)
	var pulse: int = 1 if sin(_time * 0.8) > 0.0 else 0
	_pixel_disc(center, 34 + pulse, Color(1, 0.97, 0.9, 0.3))
	_pixel_disc(center, 24, Color(1, 0.98, 0.93, 1.0))
	# A second, fainter sun that doesn't quite line up.
	_pixel_disc(center + Vector2(14, -6), 24, Color(1, 1, 1, 0.16))


func _draw_shimmer() -> void:
	for i: int in range(10):
		var width: int = 26 - i * 2
		var offset: int = int(round(sin(_time * 1.2 + float(i)) * 3.0))
		draw_rect(Rect2(470 - width / 2 + offset, HORIZON + 6 + i * 14, width, 2), Color(1, 1, 1, 0.5))


func _draw_flower() -> void:
	if _flower == null:
		return
	var sway: int = int(_time / 0.6) % 2
	var size: Vector2 = _flower.get_size() * 2.0
	draw_texture_rect(_flower, Rect2(Vector2(142 + sway, 238), size), false)
