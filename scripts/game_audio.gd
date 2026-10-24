extends Node
## One pair per looping layer for crossfades, six capped SFX voices. No idle ticks.
const FILES = ["select", "purchase", "unavailable", "ward", "discovery", "breakthrough", "panel", "strike", "enemy-hit", "collect", "flame", "river"]
var settings = {"Master": .7, "Music": 0.0, "Ambience": .12, "SFX": .35}
var muted = false
var unlocked = false
var paused = false
var preferences_path = "user://audio.cfg"
var music = []
var ambience = []
var voices = []
var streams = {}
var desired = ["music-retreat", "ambience-mountain"]
var current = ["", ""]
var transitions = [null, null]
var generations = [0, 0]
var last_effect = {}
var last_any = -100.0
var voice_index = 0
var save_delay = -1.0
var resume_gain = 1.0

func _ready() -> void:
	for name in ["Music", "Ambience", "SFX"]:
		if AudioServer.get_bus_index(name) < 0:
			AudioServer.add_bus()
			var index = AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, name)
			AudioServer.set_bus_send(index, "Master")
	load_preferences()
	for i in range(2):
		music.append(player("Music"))
		ambience.append(player("Ambience"))
	for i in range(6):
		voices.append(player("SFX"))
	for id in FILES:
		streams[id] = load("res://assets/audio/%s.wav" % id)

func player(bus: String) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	p.bus = bus
	p.max_polyphony = 1
	p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(p)
	return p

func _input(event: InputEvent) -> void:
	if not unlocked and ((event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed) or (event is InputEventKey and event.pressed and not event.echo)):
		unlocked = true
		update_loops()

func _process(delta: float) -> void:
	if not paused and resume_gain < 1:
		resume_gain = minf(1, resume_gain + delta / .4)
		apply_mix()
	if save_delay >= 0:
		save_delay -= delta
		if save_delay < 0:
			persist()

func load_preferences() -> void:
	var cfg = ConfigFile.new()
	var existed = cfg.load(preferences_path) == OK
	if existed:
		for bus in settings:
			var value: Variant = cfg.get_value("audio", bus, settings[bus])
			if (value is float or value is int) and is_finite(value):
				settings[bus] = clampf(value, 0.0, 1.0)
		muted = cfg.get_value("audio", "mute", false) == true
		if cfg.get_value("audio", "revision", 1) != 2:
			# One-time replacement of the rejected mix, not a progression reset.
			settings.Music = 0.0
			settings.Ambience = minf(settings.Ambience,.12)
			settings.SFX = minf(settings.SFX,.35)
	apply_mix()
	if existed:
		persist()

func set_volume(bus: String, volume: float) -> void:
	if not settings.has(bus) or not is_finite(volume):
		return
	settings[bus] = clampf(volume, 0, 1)
	apply_mix()
	save_delay = .25

func set_mute(value: bool) -> void:
	muted = value
	apply_mix()
	persist()

func apply_mix() -> void:
	for bus in settings:
		var index = AudioServer.get_bus_index(bus)
		var volume: float = settings[bus] * (resume_gain if bus == "Master" else 1.0)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(.0001, volume)))
		AudioServer.set_bus_mute(index, settings[bus] <= 0 or (bus == "Master" and muted))

func persist() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("audio", "revision", 2)
	for bus in settings:
		cfg.set_value("audio", bus, settings[bus])
	cfg.set_value("audio", "mute", muted)
	cfg.save(preferences_path)
	save_delay = -1

func set_scene(travelling: bool, river: bool = false) -> void:
	desired = ["music-journey" if travelling else "music-retreat", "ambience-river" if river else "ambience-mountain"]
	update_loops()

func update_loops() -> void:
	if not unlocked or paused:
		return
	for index in range(2):
		if current[index] == desired[index]:
			continue
		var pair: Array = music if index == 0 else ambience
		if transitions[index] != null:
			transitions[index].kill()
		generations[index] += 1
		var generation: int = generations[index]
		var next: AudioStreamPlayer = pair[0] if not pair[0].playing or pair[0].volume_db < pair[1].volume_db else pair[1]
		var previous: AudioStreamPlayer = pair[1] if next == pair[0] else pair[0]
		var stream: AudioStreamOggVorbis = load("res://assets/audio/%s.ogg" % desired[index])
		stream.loop = true
		next.stream = stream
		next.volume_db = -60
		next.play()
		var tween = create_tween().set_parallel(true)
		tween.tween_property(next, "volume_db", 0.0, .8)
		tween.tween_property(previous, "volume_db", -60.0, .8)
		tween.chain().tween_callback(func():
			if generations[index] == generation:
				previous.stop())
		transitions[index] = tween
		current[index] = desired[index]

func effect(id: String) -> void:
	if not unlocked or paused or muted or not streams.has(id):
		return
	var now = Time.get_ticks_msec() / 1000.0
	var gap: float = {"strike":2.5,"enemy-hit":4.0,"discovery":1.5,"breakthrough":2.0}.get(id,.18)
	if now - last_effect.get(id, -100) < gap or now - last_any < .1:
		return
	last_effect[id] = now
	last_any = now
	var p: AudioStreamPlayer = voices[voice_index]
	voice_index = (voice_index + 1) % voices.size()
	p.stream = streams[id]
	p.play()

func suspend_audio() -> void:
	paused = true
	resume_gain = 0.0
	apply_mix()
	persist()
	for p in music + ambience:
		p.stream_paused = true
	for p in voices:
		p.stop()

func resume_audio() -> void:
	if not paused:
		return
	paused = false
	for p in music + ambience:
		p.stream_paused = false
	update_loops()
