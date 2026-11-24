class_name CozyUITheme
extends RefCounted

## Palette sampled from Violet's sprite sheet and the rainy atmosphere.
const COL_PAPER_BG := Color("#F5F0E6")
const COL_PAPER_SHADOW := Color("#C9C0B1")
const COL_DARK_SLATE := Color("#22242E")
const COL_UNIFORM_BLUE := Color("#4A5D75")
const COL_SWEATER_TAUPE := Color("#9A8678")
const COL_VIOLET_ACCENT := Color("#8B72BE")
const COL_INK_TEXT := Color("#2B2930")
const COL_LIGHT_TEXT := Color("#F5F0E6")
const COL_MUTED_TEXT := Color("#7A7582")


static func build_theme(custom_font: Font = null) -> Theme:
	var theme: Theme = Theme.new()
	if custom_font != null:
		theme.default_font = custom_font

	var paper_panel: StyleBoxFlat = create_paper_box(COL_PAPER_BG, COL_UNIFORM_BLUE, 2, 4)
	theme.set_stylebox("panel", "PanelContainer", paper_panel)
	theme.set_stylebox("panel", "Panel", paper_panel)

	var button_normal: StyleBoxEmpty = StyleBoxEmpty.new()
	button_normal.content_margin_left = 12.0
	button_normal.content_margin_right = 12.0
	button_normal.content_margin_top = 4.0
	button_normal.content_margin_bottom = 4.0

	var button_focus: StyleBoxFlat = StyleBoxFlat.new()
	button_focus.bg_color = Color(COL_UNIFORM_BLUE, 0.15)
	button_focus.border_color = COL_VIOLET_ACCENT
	button_focus.border_width_left = 4
	button_focus.content_margin_left = 12.0
	button_focus.content_margin_right = 12.0
	button_focus.content_margin_top = 4.0
	button_focus.content_margin_bottom = 4.0

	theme.set_stylebox("normal", "Button", button_normal)
	theme.set_stylebox("hover", "Button", button_focus)
	theme.set_stylebox("focus", "Button", button_focus)
	theme.set_stylebox("pressed", "Button", button_focus)
	theme.set_color("font_color", "Button", COL_MUTED_TEXT)
	theme.set_color("font_hover_color", "Button", COL_INK_TEXT)
	theme.set_color("font_focus_color", "Button", COL_INK_TEXT)
	theme.set_color("font_pressed_color", "Button", COL_VIOLET_ACCENT)
	theme.set_color("font_color", "Label", COL_INK_TEXT)
	return theme


static func create_paper_box(
	bg: Color = COL_PAPER_BG,
	border: Color = COL_UNIFORM_BLUE,
	border_px: int = 2,
	shadow_px: int = 4
) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_px)
	box.set_corner_radius_all(2)
	box.shadow_color = Color(0.12, 0.13, 0.18, 0.35)
	box.shadow_size = 0
	box.shadow_offset = Vector2(shadow_px, shadow_px)
	box.content_margin_left = 16.0
	box.content_margin_right = 16.0
	box.content_margin_top = 10.0
	box.content_margin_bottom = 10.0
	return box


static func create_dialogue_box() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(COL_DARK_SLATE, 0.94)
	box.border_color = COL_SWEATER_TAUPE
	box.set_border_width_all(3)
	box.set_corner_radius_all(2)
	box.content_margin_left = 20.0
	box.content_margin_right = 20.0
	box.content_margin_top = 14.0
	box.content_margin_bottom = 14.0
	return box


static func create_objective_tag() -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(COL_PAPER_BG, 0.95)
	box.border_color = COL_VIOLET_ACCENT
	box.border_width_left = 5
	box.border_width_top = 1
	box.border_width_right = 1
	box.border_width_bottom = 1
	box.shadow_color = Color(0, 0, 0, 0.25)
	box.shadow_offset = Vector2(2, 2)
	box.content_margin_left = 12.0
	box.content_margin_right = 14.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	return box
