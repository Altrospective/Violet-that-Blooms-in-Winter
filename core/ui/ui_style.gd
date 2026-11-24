class_name UiStyle
extends RefCounted
## Sketchbook-style frames: pencil-drawn, slightly wobbly borders with batik (kawung)
## corner ornaments. The art lives in assets/ui and is rebuilt by tools/generate_art.py.
## Falls back to plain boxes if the textures are missing.

const FRAME_DARK: String = "res://assets/ui/frame_dark.png"
const FRAME_PAPER: String = "res://assets/ui/frame_paper.png"
const CURSOR: String = "res://assets/ui/cursor_pencil.png"
const MARGIN: int = 16


## Dark box with pale pencil lines and amber batik corners (dialogue, content note).
static func dark_frame() -> StyleBox:
	return _frame(FRAME_DARK, Color(0.07, 0.06, 0.1, 0.94), Color(0.92, 0.9, 0.95))


## Cream paper with violet pencil lines and soga-red batik corners (menu, portraits).
static func paper_frame() -> StyleBox:
	return _frame(FRAME_PAPER, Color(0.96, 0.93, 0.88, 0.94), Color(0.3, 0.23, 0.4))


static func cursor_texture() -> Texture2D:
	if ResourceLoader.exists(CURSOR):
		return load(CURSOR) as Texture2D
	return null


static func _frame(path: String, fallback_fill: Color, fallback_border: Color) -> StyleBox:
	if ResourceLoader.exists(path):
		var style: StyleBoxTexture = StyleBoxTexture.new()
		style.texture = load(path) as Texture2D
		style.texture_margin_left = MARGIN
		style.texture_margin_right = MARGIN
		style.texture_margin_top = MARGIN
		style.texture_margin_bottom = MARGIN
		style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
		return style
	var flat: StyleBoxFlat = StyleBoxFlat.new()
	flat.bg_color = fallback_fill
	flat.border_color = fallback_border
	flat.set_border_width_all(2)
	return flat
