extends SceneTree
const Audio = preload("res://scripts/game_audio.gd")
var checks = 0
var failures = 0
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func playing(nodes: Array) -> int:
	return nodes.filter(func(p): return p.playing).size()
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var audio = Audio.new()
	audio.preferences_path = "res://.verification/audio-isolated-%d.cfg" % Time.get_ticks_usec()
	root.add_child(audio)
	check(audio.settings.Music==0 and audio.settings.Ambience==.12 and audio.settings.SFX==.35,"New default mix has music off and quiet organic layers")
	check(playing(audio.music)==0 and playing(audio.ambience)==0,"No automatic playback before gesture")
	var tap = InputEventMouseButton.new()
	tap.button_index = MOUSE_BUTTON_LEFT
	tap.pressed = true
	audio._input(tap)
	await create_timer(1).timeout
	check(playing(audio.music)==1 and playing(audio.ambience)==1,"One music and ambience loop after unlock")
	for river in [true,false,true,false]:
		audio.set_scene(true,river)
		await create_timer(.08).timeout
	await create_timer(1).timeout
	check(playing(audio.music)==1 and playing(audio.ambience)==1,"Canceled crossfades stop obsolete loops")
	check(audio.current==["music-journey","ambience-mountain"],"Final scene wins rapid transitions")
	audio.effect("strike")
	audio.effect("strike")
	check(playing(audio.voices)<=1 and audio.voices.size()==6,"Effect debounce and fixed voice budget")
	audio.suspend_audio()
	check((audio.music+audio.ambience).all(func(p): return not p.playing or p.stream_paused),"Background pauses every playing loop")
	for i in range(10): audio.resume_audio()
	check(audio.music.size()==2 and audio.ambience.size()==2 and playing(audio.music)==1 and playing(audio.ambience)==1,"Repeated focus does not duplicate players or loops")
	check(audio.resume_gain == 0,"Focus return starts quietly")
	await create_timer(.5).timeout
	check(audio.resume_gain == 1,"Existing mix fades back within half a second")
	audio.set_volume("Music",0)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Music")),"Music bus zero mutes its actual bus")
	audio.set_volume("Music",.42)
	audio.set_volume("Master",.65)
	audio.set_mute(true)
	var restored = Audio.new()
	restored.preferences_path = audio.preferences_path
	root.add_child(restored)
	check(restored.muted and restored.settings.Music==.42 and restored.settings.Master==.65,"Mix and mute persist separately from progress")
	check(not restored.unlocked and playing(restored.music)==0,"Reload still waits for gesture")
	var legacy_cfg = ConfigFile.new()
	legacy_cfg.set_value("audio","Master",.62)
	legacy_cfg.set_value("audio","Music",.55)
	legacy_cfg.set_value("audio","Ambience",.7)
	legacy_cfg.set_value("audio","SFX",.8)
	legacy_cfg.set_value("audio","mute",true)
	legacy_cfg.save(audio.preferences_path+"-legacy")
	var legacy = Audio.new()
	legacy.preferences_path = audio.preferences_path+"-legacy"
	root.add_child(legacy)
	check(legacy.settings.Master==.62 and legacy.muted and legacy.settings.Music==0 and legacy.settings.Ambience==.12 and legacy.settings.SFX==.35,"Old rejected mix quiets once while Master/mute remain")
	legacy.set_volume("Music",.23)
	legacy.persist()
	legacy.load_preferences()
	check(legacy.settings.Music==.23,"Player's later music preference survives revision-two reload")
	legacy.queue_free()
	audio.queue_free()
	restored.queue_free()
	await process_frame
	await create_timer(.1).timeout
	print("Jade audio: %d checks; %d failures; signal/routing only, no listening claim" % [checks,failures])
	quit(1 if failures else 0)
