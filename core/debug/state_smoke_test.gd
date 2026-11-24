extends Node
## Quick sanity check for GameState and EndingEvaluator.
## Runs when you press F5 on the default Main scene. Results print to the Output panel.
## Delete this script and detach it from core/main.tscn once real scenes exist.

var scene_title: String = "GameState Smoke Test"
var _failures: int = 0


func _ready() -> void:
	_test_the_bloom()
	_test_shatter_cap_blocks_bloom()
	_test_tragic()
	_test_bad()
	_test_neutral()
	_test_save_roundtrip()
	if _failures == 0:
		print("GameState smoke test: all checks passed")
	else:
		push_error("GameState smoke test: %d check(s) failed" % _failures)


func _check(label: String, got: Variant, expected: Variant) -> void:
	if got == expected:
		print("  ok    %s" % label)
	else:
		_failures += 1
		printerr("  FAIL  %s: got %s, expected %s" % [label, got, expected])


func _test_the_bloom() -> void:
	GameState.reset()
	GameState.set_score(&"vulnerability", 5.0)
	GameState.set_score(&"self_worth", 5.0)
	GameState.set_score(&"rey_trust", 5.0)
	GameState.set_score(&"karin_insight", 5.0)
	GameState.shatter_memory(&"m1")
	GameState.shatter_memory(&"m2")
	_check("effective vulnerability after 2 shatters", GameState.get_effective_vulnerability(), 4.0)
	_check("The Bloom", GameState.evaluate_ending(), EndingEvaluator.THE_BLOOM)


func _test_shatter_cap_blocks_bloom() -> void:
	GameState.reset()
	GameState.set_score(&"vulnerability", 5.0)
	GameState.set_score(&"self_worth", 5.0)
	GameState.set_score(&"rey_trust", 5.0)
	GameState.set_score(&"karin_insight", 5.0)
	GameState.set_score(&"empathy", 5.0)
	for i: int in range(7):
		GameState.shatter_memory(StringName("m%d" % i))
	_check("effective vulnerability after 7 shatters", GameState.get_effective_vulnerability(), 1.5)
	_check("7 shatters falls to Reconciliation", GameState.evaluate_ending(), EndingEvaluator.WHAT_WE_DIDNT_KNOW)


func _test_tragic() -> void:
	GameState.reset()
	GameState.set_score(&"vulnerability", -5.0)
	GameState.set_score(&"self_worth", -5.0)
	GameState.set_flag(&"support_rey_rejected")
	GameState.set_flag(&"support_report_rejected")
	GameState.set_flag(&"support_counselor_rejected")
	_check("Snow Falls Quietly", GameState.evaluate_ending(), EndingEvaluator.SNOW_FALLS_QUIETLY)


func _test_bad() -> void:
	GameState.reset()
	GameState.set_score(&"vulnerability", -3.0)
	GameState.set_score(&"empathy", -3.0)
	_check("Familiar Silence", GameState.evaluate_ending(), EndingEvaluator.FAMILIAR_SILENCE)


func _test_neutral() -> void:
	GameState.reset()
	_check("Another Day", GameState.evaluate_ending(), EndingEvaluator.ANOTHER_DAY)


func _test_save_roundtrip() -> void:
	GameState.reset()
	GameState.set_score(&"empathy", 2.5)
	GameState.set_flag(&"teacher_reported")
	GameState.shatter_memory(&"m1")
	var snapshot: Dictionary = GameState.to_dict()
	GameState.reset()
	var result: Error = GameState.from_dict(snapshot)
	_check("from_dict returns OK", result, OK)
	_check("empathy restored", GameState.get_score(&"empathy"), 2.5)
	_check("flag restored", GameState.has_flag(&"teacher_reported"), true)
	_check("shatter restored", GameState.get_shattered_count(), 1)
	GameState.reset()
