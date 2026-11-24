extends Node
## Global story state for "Violet that Blooms in Winter".
## Registered as the autoload "GameState" in project.godot.
##
## Scores (all -5 to +5): vulnerability, self_worth, empathy, rey_trust, karin_insight.
## Flags (bool): teacher_reported, support_*_rejected, plus any story flag you add.
## Memories: up to 10 can be shattered. Each shattered memory costs 0.5 effective
## vulnerability. get_score(&"vulnerability") is the BASE value; use
## get_effective_vulnerability() for anything that should reflect withdrawal.

signal score_changed(score: StringName, old_value: float, new_value: float)
signal flag_changed(flag: StringName, value: bool)
signal memory_shattered(memory_id: StringName, shattered_count: int)
signal withdrawal_changed(shattered_count: int, effective_vulnerability: float)
signal ending_resolved(ending_id: StringName)
signal state_loaded

const SCORE_MIN: float = -5.0
const SCORE_MAX: float = 5.0
const TOTAL_MEMORIES: int = 10
const SHATTER_VULNERABILITY_PENALTY: float = 0.5
const SAVE_PATH: String = "user://save.json"
const SAVE_VERSION: int = 1

const SCORE_NAMES: Array[StringName] = [
	&"vulnerability", &"self_worth", &"empathy", &"rey_trust", &"karin_insight",
]
const DEFAULT_FLAGS: Array[StringName] = [
	&"teacher_reported",
	&"support_rey_rejected",
	&"support_report_rejected",
	&"support_counselor_rejected",
]

var _scores: Dictionary = {}
var _flags: Dictionary = {}
var _shattered: Array[StringName] = []


func _ready() -> void:
	reset()


func reset() -> void:
	_scores.clear()
	_flags.clear()
	_shattered.clear()
	for score_name: StringName in SCORE_NAMES:
		_scores[score_name] = 0.0
	for flag_name: StringName in DEFAULT_FLAGS:
		_flags[flag_name] = false
	withdrawal_changed.emit(0, get_effective_vulnerability())


# ---------- Scores ----------

func get_score(score_name: StringName) -> float:
	if not _scores.has(score_name):
		push_error("GameState: unknown score '%s'" % score_name)
		return 0.0
	return _scores[score_name]


func set_score(score_name: StringName, value: float) -> void:
	if not _scores.has(score_name):
		push_error("GameState: unknown score '%s'" % score_name)
		return
	var old_value: float = _scores[score_name]
	var new_value: float = clampf(value, SCORE_MIN, SCORE_MAX)
	if is_equal_approx(old_value, new_value):
		return
	_scores[score_name] = new_value
	score_changed.emit(score_name, old_value, new_value)
	if score_name == &"vulnerability":
		withdrawal_changed.emit(_shattered.size(), get_effective_vulnerability())


func add_score(score_name: StringName, delta: float) -> void:
	set_score(score_name, get_score(score_name) + delta)


func get_effective_vulnerability() -> float:
	var base: float = _scores[&"vulnerability"]
	var penalty: float = SHATTER_VULNERABILITY_PENALTY * _shattered.size()
	return clampf(base - penalty, SCORE_MIN, SCORE_MAX)


# ---------- Flags ----------

func set_flag(flag_name: StringName, value: bool = true) -> void:
	var old_value: bool = _flags.get(flag_name, false)
	_flags[flag_name] = value
	if old_value != value:
		flag_changed.emit(flag_name, value)


func has_flag(flag_name: StringName) -> bool:
	return _flags.get(flag_name, false)


# ---------- Inner Winter memories ----------

## Returns true if the memory was newly shattered.
func shatter_memory(memory_id: StringName) -> bool:
	if _shattered.has(memory_id):
		return false
	if _shattered.size() >= TOTAL_MEMORIES:
		push_warning("GameState: all %d memories are already shattered" % TOTAL_MEMORIES)
		return false
	_shattered.append(memory_id)
	memory_shattered.emit(memory_id, _shattered.size())
	withdrawal_changed.emit(_shattered.size(), get_effective_vulnerability())
	return true


func is_memory_shattered(memory_id: StringName) -> bool:
	return _shattered.has(memory_id)


func get_shattered_count() -> int:
	return _shattered.size()


## 0.0 (nothing shattered) to 1.0 (all shattered). Handy for shaders and UI.
func get_withdrawal_ratio() -> float:
	return float(_shattered.size()) / float(TOTAL_MEMORIES)


# ---------- Endings ----------

func get_ending_snapshot() -> Dictionary:
	return {
		"effective_vulnerability": get_effective_vulnerability(),
		"self_worth": _scores[&"self_worth"],
		"empathy": _scores[&"empathy"],
		"rey_trust": _scores[&"rey_trust"],
		"karin_insight": _scores[&"karin_insight"],
		"shattered_count": _shattered.size(),
		"support_rey_rejected": has_flag(&"support_rey_rejected"),
		"support_report_rejected": has_flag(&"support_report_rejected"),
		"support_counselor_rejected": has_flag(&"support_counselor_rejected"),
	}


## Preview only: does not emit a signal.
func evaluate_ending() -> StringName:
	return EndingEvaluator.evaluate(get_ending_snapshot())


## Use this at the climax branch point.
func resolve_ending() -> StringName:
	var ending_id: StringName = evaluate_ending()
	ending_resolved.emit(ending_id)
	return ending_id


# ---------- Save / load ----------

func to_dict() -> Dictionary:
	var scores_out: Dictionary = {}
	for score_name: StringName in _scores:
		scores_out[String(score_name)] = _scores[score_name]
	var flags_out: Dictionary = {}
	for flag_name: StringName in _flags:
		flags_out[String(flag_name)] = _flags[flag_name]
	var shattered_out: Array[String] = []
	for memory_id: StringName in _shattered:
		shattered_out.append(String(memory_id))
	return {
		"version": SAVE_VERSION,
		"scores": scores_out,
		"flags": flags_out,
		"shattered": shattered_out,
	}


func from_dict(data: Dictionary) -> Error:
	if int(data.get("version", -1)) != SAVE_VERSION:
		return ERR_INVALID_DATA
	reset()
	var scores_in: Dictionary = data.get("scores", {})
	for score_name: StringName in SCORE_NAMES:
		var raw: float = float(scores_in.get(String(score_name), 0.0))
		_scores[score_name] = clampf(raw, SCORE_MIN, SCORE_MAX)
	var flags_in: Dictionary = data.get("flags", {})
	for key: Variant in flags_in:
		_flags[StringName(str(key))] = bool(flags_in[key])
	var shattered_in: Array = data.get("shattered", [])
	for memory_id: Variant in shattered_in:
		var id: StringName = StringName(str(memory_id))
		if not _shattered.has(id) and _shattered.size() < TOTAL_MEMORIES:
			_shattered.append(id)
	state_loaded.emit()
	withdrawal_changed.emit(_shattered.size(), get_effective_vulnerability())
	return OK


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> Error:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(to_dict(), "\t"))
	return OK


func load_game() -> Error:
	if not has_save():
		return ERR_FILE_NOT_FOUND
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		return ERR_PARSE_ERROR
	var data: Dictionary = parsed
	return from_dict(data)
