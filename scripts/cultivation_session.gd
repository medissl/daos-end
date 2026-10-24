extends RefCounted
## One clock owner: monotonic while active, wall time only while absent.
const Rules = preload("res://scripts/progression.gd")
var state: RefCounted
var active = true
var last_tick: float
var absent_since: float

func _init(game_state: RefCounted, now: float, tick: float) -> void:
	state = game_state
	absent_since = now
	last_tick = tick

func update(tick: float) -> void:
	if active:
		state.advance(maxf(0.0, tick - last_tick))
		last_tick = tick

func suspend(now: float, tick: float) -> void:
	if active:
		update(tick)
		active = false
		absent_since = now

func resume(now: float, tick: float) -> Dictionary:
	if active:
		return {"seconds": 0.0, "qi": 0.0, "herbs": 0, "trips": 0}
	var seconds = clampf(now - absent_since, 0.0, Rules.MAX_OFFLINE_SECONDS)
	var reward: Dictionary = state.advance(seconds, true)
	active = true
	last_tick = tick
	absent_since = now
	return reward

func restore(saved_at: float, now: float, tick: float, legacy_rate: float = -1.0) -> Dictionary:
	# V1 had no expeditions or techniques. Honor its original rate exactly once.
	if legacy_rate >= 0.0:
		var seconds = clampf(now - saved_at, 0.0, Rules.MAX_OFFLINE_SECONDS)
		var earned = seconds * legacy_rate
		state.qi += earned
		last_tick = tick
		absent_since = now
		active = true
		return {"seconds": seconds, "qi": earned, "herbs": 0, "trips": 0}
	active = false
	absent_since = saved_at
	return resume(now, tick)
