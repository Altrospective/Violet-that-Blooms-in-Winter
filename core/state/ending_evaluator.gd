class_name EndingEvaluator
extends RefCounted
## Picks the ending from a state snapshot. Checked top to bottom; first match wins.
##
## Snapshot keys (see GameState.get_ending_snapshot()):
##   effective_vulnerability, self_worth, empathy, rey_trust, karin_insight (floats, -5..+5)
##   shattered_count (int)
##   support_rey_rejected, support_report_rejected, support_counselor_rejected (bool)

const THE_BLOOM: StringName = &"the_bloom"
const WHAT_WE_DIDNT_KNOW: StringName = &"what_we_didnt_know"
const SNOW_FALLS_QUIETLY: StringName = &"snow_falls_quietly"
const FAMILIAR_SILENCE: StringName = &"familiar_silence"
const ANOTHER_DAY: StringName = &"another_day"

const SCORE_FLOOR: float = -5.0

## High is +3 or more, moderate is -1 to +2, low is -2 or less.
const HIGH_MIN: float = 3.0
const MODERATE_MIN: float = -1.0
const MODERATE_MAX: float = 2.0
const LOW_MAX: float = -2.0

## Shatter limits: The Bloom allows 6 or fewer, Reconciliation allows 8 or fewer.
const BLOOM_MAX_SHATTERED: int = 6
const RECONCILIATION_MAX_SHATTERED: int = 8


static func evaluate(s: Dictionary) -> StringName:
	var ev: float = s.get("effective_vulnerability", 0.0)
	var self_worth: float = s.get("self_worth", 0.0)
	var empathy: float = s.get("empathy", 0.0)
	var rey_trust: float = s.get("rey_trust", 0.0)
	var karin_insight: float = s.get("karin_insight", 0.0)
	var shattered: int = s.get("shattered_count", 0)

	# 1. The Bloom
	if shattered <= BLOOM_MAX_SHATTERED \
			and _is_high(ev) and _is_high(self_worth) \
			and _is_high(rey_trust) and _is_high(karin_insight):
		return THE_BLOOM

	# 2. What We Didn't Know
	if shattered <= RECONCILIATION_MAX_SHATTERED \
			and _is_high(empathy) and _is_high(karin_insight) \
			and _is_moderate(ev):
		return WHAT_WE_DIDNT_KNOW

	# 3. Snow Falls Quietly (checked before Familiar Silence: stricter conditions)
	if ev <= SCORE_FLOOR and self_worth <= SCORE_FLOOR \
			and s.get("support_rey_rejected", false) \
			and s.get("support_report_rejected", false) \
			and s.get("support_counselor_rejected", false):
		return SNOW_FALLS_QUIETLY

	# 4. Familiar Silence
	if _is_low(ev) and _is_low(empathy):
		return FAMILIAR_SILENCE

	# 5. Another Day (fall-through)
	return ANOTHER_DAY


static func _is_high(value: float) -> bool:
	return value >= HIGH_MIN


static func _is_moderate(value: float) -> bool:
	return value >= MODERATE_MIN and value <= MODERATE_MAX


static func _is_low(value: float) -> bool:
	return value <= LOW_MAX
