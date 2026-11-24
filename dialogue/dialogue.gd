extends CanvasLayer
## Typewriter dialogue box. Registered as the autoload "Dialogue".
##
## Line format (matches the dialogue JSON files):
##   {"speaker": "rey", "portrait": "Warm Smile", "text": "Eh...{pause=0.4} found you."}
##   {"type": "direction", "text": "Wind."}     shown in parentheses, no portrait or blips
##   {"type": "narration", "text": "A desk."}   shown plainly, no portrait or blips
## Inline tags: {pause=0.5} waits that many seconds; {speed=18} sets characters per
## second for the rest of the line; {speed=default} resets it.
##
## Layout: box at the bottom. The protagonist's portrait is on the left, everyone
## else's on the right (set per speaker in speakers.json).

signal dialogue_started
signal dialogue_finished
signal line_started(speaker: StringName, portrait: String)

const SPEAKERS_PATH: String = "res://dialogue/speakers.json"
const PORTRAIT_DIR: String = "res://assets/portraits"

const DEFAULT_CPS: float = 40.0
const BLIP_EVERY: int = 2

const BOX_RECT: Rect2 = Rect2(16, 248, 608, 96)
const PORTRAIT_SIZE: float = 72.0
const PADDING: float = 14.0

var is_active: bool = false

var _speakers: Dictionary = {}
var _lines: Array = []
var _line_index: int = -1

var _typing: bool = false
var _plain_text: String = ""
var _events: Dictionary = {}
var _cps: float = DEFAULT_CPS
var _char_budget: float = 0.0
var _pause_left: float = 0.0
var _shown: int = 0
var _total: int = 0
var _blip_enabled: bool = false
var _blip_countdown: int = 0
var _blink_time: float = 0.0

var _root: Control
var _box: Panel
var _name_label: Label
var _text_label: RichTextLabel
var _continue_label: Label
var _portrait_frames: Dictionary = {}
var _blip: AudioStreamPlayer


func _ready() -> void:
	layer = 10
	InputActions.ensure_registered()
	_load_speakers()
	_build_ui()
	_root.visible = false
	set_process(false)


# ---------- Public API ----------

func start(lines: Array) -> void:
	if is_active or lines.is_empty():
		return
	_lines = lines
	_line_index = -1
	is_active = true
	_root.visible = true
	set_process(true)
	dialogue_started.emit()
	_next_line()


func start_from_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_error("Dialogue: file not found '%s'" % path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Dialogue: '%s' is not a valid dialogue file" % path)
		return
	var data: Dictionary = parsed
	if not data.has("lines"):
		push_error("Dialogue: '%s' has no \"lines\" array" % path)
		return
	start(data["lines"])


func start_narration(texts: PackedStringArray) -> void:
	var lines: Array = []
	for text: String in texts:
		lines.append({"type": "narration", "text": text})
	start(lines)


# ---------- Input ----------

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	if event.is_action_pressed(InputActions.INTERACT):
		get_viewport().set_input_as_handled()
		_advance()


func _advance() -> void:
	if _typing:
		_events.clear()
		_finish_typing()
	else:
		_next_line()


# ---------- Lines ----------

func _next_line() -> void:
	_line_index += 1
	if _line_index >= _lines.size():
		_end()
		return
	var line: Dictionary = _lines[_line_index]
	_show_line(line)


func _end() -> void:
	is_active = false
	_typing = false
	_root.visible = false
	set_process(false)
	dialogue_finished.emit()


func _show_line(line: Dictionary) -> void:
	var kind: String = str(line.get("type", "speech"))
	var raw: String = str(line.get("text", ""))
	var speaker: StringName = &""
	var portrait: String = ""
	var info: Dictionary = {}

	if kind == "direction":
		raw = "(%s)" % raw
	elif kind != "narration":
		speaker = StringName(str(line.get("speaker", "")))
		portrait = str(line.get("portrait", ""))
		info = _speakers.get(String(speaker), {})

	for frame: Variant in _portrait_frames.values():
		(frame as Panel).visible = false

	var side: String = ""
	var display_name: String = ""
	if speaker != &"":
		display_name = str(info.get("name", String(speaker).capitalize()))
		side = str(info.get("side", "right"))
		if _portrait_frames.has(side):
			var frame: Panel = _portrait_frames[side]
			frame.visible = true
			_set_portrait(frame, speaker, portrait, info)
		_blip.pitch_scale = maxf(0.1, float(info.get("pitch", 1.0)))

	_name_label.text = display_name
	_name_label.visible = display_name != ""
	_text_label.modulate = Color(0.78, 0.78, 0.85) if kind == "direction" else Color.WHITE
	_layout_text(side, display_name != "")

	var parsed: Dictionary = _parse_tags(raw)
	_plain_text = parsed["text"]
	_events = parsed["events"]
	_text_label.text = _plain_text
	_text_label.visible_characters = 0
	_total = _plain_text.length()
	_shown = 0
	_cps = DEFAULT_CPS
	_char_budget = 0.0
	_pause_left = 0.0
	_blip_enabled = speaker != &""
	_blip_countdown = 0
	_continue_label.visible = false
	_typing = true
	line_started.emit(speaker, portrait)


# ---------- Typewriter ----------

func _process(delta: float) -> void:
	_blink_time += delta
	if not _typing:
		_continue_label.visible = is_active and int(_blink_time * 2.0) % 2 == 0
		return
	if _pause_left > 0.0:
		_pause_left -= delta
		return
	_char_budget += delta * _cps
	while _char_budget >= 1.0 and _typing:
		if _events.has(_shown):
			_apply_events(_shown)
			if _pause_left > 0.0:
				_char_budget = 0.0
				return
		if _shown >= _total:
			_finish_typing()
			return
		_shown += 1
		_text_label.visible_characters = _shown
		_char_budget -= 1.0
		_maybe_blip()


func _apply_events(index: int) -> void:
	for event: Dictionary in _events[index]:
		var value: String = event["value"]
		if event["kind"] == "pause":
			_pause_left = maxf(0.0, float(value))
		elif event["kind"] == "speed":
			_cps = DEFAULT_CPS if value == "default" else maxf(1.0, float(value))
	_events.erase(index)


func _finish_typing() -> void:
	_typing = false
	_shown = _total
	_text_label.visible_characters = -1
	_blink_time = 0.0


func _maybe_blip() -> void:
	if not _blip_enabled or _shown < 1:
		return
	if _plain_text.substr(_shown - 1, 1).strip_edges() == "":
		return
	_blip_countdown -= 1
	if _blip_countdown <= 0:
		_blip_countdown = BLIP_EVERY
		_blip.play()


## Strips {pause=..} and {speed=..} tags. Returns {"text": String, "events": Dictionary}
## where events maps a character index to the tags that fire before that character.
func _parse_tags(raw: String) -> Dictionary:
	var regex: RegEx = RegEx.new()
	regex.compile("\\{(pause|speed)=([^}]*)\\}")
	var out: String = ""
	var events: Dictionary = {}
	var cursor: int = 0
	for m: RegExMatch in regex.search_all(raw):
		out += raw.substr(cursor, m.get_start() - cursor)
		cursor = m.get_end()
		var index: int = out.length()
		if not events.has(index):
			events[index] = []
		(events[index] as Array).append({"kind": m.get_string(1), "value": m.get_string(2)})
	out += raw.substr(cursor)
	return {"text": out, "events": events}


# ---------- Portraits ----------

func _set_portrait(frame: Panel, speaker: StringName, portrait: String, info: Dictionary) -> void:
	var tint: Color = Color.html(str(info.get("color", "#555566")))
	frame.self_modulate = tint.lightened(0.6)
	var texture_rect: TextureRect = frame.get_node("Texture")
	var placeholder: Label = frame.get_node("Placeholder")
	var slug: String = portrait.to_lower().replace(" ", "_").replace("/", "_")
	var path: String = "%s/%s/%s.png" % [PORTRAIT_DIR, String(speaker), slug]
	if portrait != "" and ResourceLoader.exists(path):
		texture_rect.texture = load(path) as Texture2D
		texture_rect.visible = true
		placeholder.visible = false
	else:
		texture_rect.texture = null
		texture_rect.visible = false
		placeholder.text = portrait if portrait != "" else String(speaker)
		placeholder.visible = true


# ---------- UI construction ----------

func _load_speakers() -> void:
	if not FileAccess.file_exists(SPEAKERS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SPEAKERS_PATH))
	if typeof(parsed) == TYPE_DICTIONARY:
		_speakers = parsed


func _make_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	return style


func _build_ui() -> void:
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_box = Panel.new()
	_box.position = BOX_RECT.position
	_box.size = BOX_RECT.size
	_box.add_theme_stylebox_override("panel", UiStyle.dark_frame())
	_root.add_child(_box)

	_name_label = Label.new()
	_name_label.add_theme_font_size_override("font_size", 12)
	_box.add_child(_name_label)

	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = false
	_text_label.scroll_active = false
	_text_label.add_theme_font_size_override("normal_font_size", 14)
	_box.add_child(_text_label)

	_continue_label = Label.new()
	_continue_label.text = "E / Z / Enter / Space: continue"
	_continue_label.position = Vector2(BOX_RECT.size.x - 256.0, BOX_RECT.size.y - 26.0)
	_continue_label.size = Vector2(240, 16)
	_continue_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_continue_label.add_theme_font_size_override("font_size", 9)
	_continue_label.visible = false
	_box.add_child(_continue_label)

	for side: String in ["left", "right"]:
		var frame: Panel = Panel.new()
		frame.size = Vector2(PORTRAIT_SIZE, PORTRAIT_SIZE)
		frame.add_theme_stylebox_override("panel", UiStyle.paper_frame())
		var x: float = PADDING if side == "left" else BOX_RECT.size.x - PADDING - PORTRAIT_SIZE
		frame.position = Vector2(x, (BOX_RECT.size.y - PORTRAIT_SIZE) * 0.5)
		frame.visible = false
		_box.add_child(frame)

		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.name = "Texture"
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		frame.add_child(texture_rect)
		texture_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		var placeholder: Label = Label.new()
		placeholder.name = "Placeholder"
		placeholder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		placeholder.add_theme_font_size_override("font_size", 10)
		placeholder.add_theme_color_override("font_color", Color(0.2, 0.15, 0.28))
		frame.add_child(placeholder)
		placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

		_portrait_frames[side] = frame

	_blip = AudioStreamPlayer.new()
	_blip.stream = _make_beep()
	_blip.volume_db = -8.0
	add_child(_blip)


func _layout_text(side: String, has_name: bool) -> void:
	var left: float = PADDING
	var right: float = PADDING
	if side == "left":
		left += PORTRAIT_SIZE + 10.0
	elif side == "right":
		right += PORTRAIT_SIZE + 10.0
	var width: float = BOX_RECT.size.x - left - right
	var name_height: float = 16.0 if has_name else 0.0
	_name_label.position = Vector2(left, 10.0)
	_name_label.size = Vector2(width, 16.0)
	_text_label.position = Vector2(left, 10.0 + name_height)
	_text_label.size = Vector2(width, BOX_RECT.size.y - 20.0 - name_height)


## A short soft beep generated in code. Pitch is shifted per character via pitch_scale.
func _make_beep() -> AudioStreamWAV:
	var mix_rate: int = 22050
	var sample_count: int = int(mix_rate * 0.06)
	var data: PackedByteArray = PackedByteArray()
	data.resize(sample_count * 2)
	for i: int in range(sample_count):
		var t: float = float(i) / float(mix_rate)
		var envelope: float = 1.0 - float(i) / float(sample_count)
		var value: float = sin(TAU * 440.0 * t) * 0.3 * envelope
		data.encode_s16(i * 2, int(value * 32767.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = mix_rate
	wav.stereo = false
	wav.data = data
	return wav
