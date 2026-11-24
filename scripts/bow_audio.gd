extends Node

const Timbres := preload("res://scripts/arrow_timbres.gd")
# Small original sounds generated once. All voices may overlap the bowstring.
const MIX_RATE := 22050
const LENGTHS := {
	"shot": 0.21, "hit": 0.15, "miss": 0.08, "empty": 0.09,
	"pickup": 0.24, "buy": 0.43, "break": 0.43, "win": 0.95, "branch": 0.14,
	"target": 0.35, "event": 0.55, "spark": 0.24,
}
var _voices: Dictionary = {}
var _options := {}
var _preview_voices := {}
var _original := {}
var _generated := {}
var _preview_generation := 0
var _impact_frame := -1


func _ready() -> void:
	for cue: String in LENGTHS:
		var voice := AudioStreamPlayer.new()
		voice.stream = _make_clip(cue, LENGTHS[cue])
		if cue == "buy" or cue == "win":
			voice.process_mode = Node.PROCESS_MODE_ALWAYS
		voice.max_polyphony = 2
		add_child(voice)
		_voices[cue] = voice
	_original = {Timbres.SHOT: _voices.shot.stream, Timbres.IMPACT: _voices.hit.stream}
	var impact := AudioStreamPlayer.new()
	add_child(impact)
	_voices["arrow_impact"] = impact
	for cue: String in ["shot", "arrow_impact"]:
		_voices[cue].max_polyphony = 3
		var preview_voice := AudioStreamPlayer.new()
		preview_voice.max_polyphony = 3
		preview_voice.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(preview_voice)
		_preview_voices[cue] = preview_voice
	get_window().focus_exited.connect(stop_preview)
	apply_settings(_options)

func apply_settings(options: Dictionary) -> void:
	_options = options
	for cue: String in _voices:
		var group := "volume_world"
		if cue in ["shot", "empty", "branch"]:
			group = "volume_bow"
		elif cue in ["buy", "win"]:
			group = "volume_ui"
		var mix := clampf(options.get(group, 1.0), 0, 1)
		var voice := _voices[cue] as AudioStreamPlayer
		var base_db := -7.0 if cue == "pickup" else -10.0
		if cue in _preview_voices:
			var setting := Timbres.SHOT if cue == "shot" else Timbres.IMPACT
			var id := Timbres.selected(setting, options.get(setting))
			var entry: Array = Timbres.CATALOG[setting][id]
			var stream: AudioStream = entry[2]
			if stream == null:
				if id == "original":
					stream = _original[setting]
				else:
					if not _generated.has(id):
						_generated[id] = Timbres.synthesize(setting, id)
					stream = _generated[id]
			if voice.stream != stream:
				voice.stream = stream
			if _preview_voices[cue].stream != stream:
				_preview_voices[cue].stream = stream
			base_db += float(entry[3])
		voice.volume_db = base_db + linear_to_db(maxf(mix, 0.00001))
		if cue in _preview_voices:
			_preview_voices[cue].volume_db = voice.volume_db


func play(cue: String) -> void:
	if cue == "arrow_impact":
		# Several arrows can land together. One wood transient per physics tick
		# keeps multishot from tripling the gain of an identical sample.
		if _impact_frame == Engine.get_physics_frames():
			return
		_impact_frame = Engine.get_physics_frames()
	var voice: AudioStreamPlayer = _voices.get(cue)
	if voice != null:
		voice.play()

func stop_preview() -> void:
	_preview_generation += 1
	for voice: AudioStreamPlayer in _preview_voices.values():
		voice.stop()

func preview(pattern: String) -> void:
	stop_preview()
	if pattern in _preview_voices:
		_preview_voices[pattern].play()
		return
	if pattern not in ["pair", "burst"]:
		return
	var ticket := _preview_generation
	var count := 6 if pattern == "burst" else 1
	for i in count:
		_preview_voices.shot.play()
		await get_tree().create_timer(0.08, true, false, true).timeout
		if ticket != _preview_generation:
			return
		_preview_voices.arrow_impact.play()
		if i + 1 < count:
			await get_tree().create_timer(0.05, true, false, true).timeout
			if ticket != _preview_generation:
				return


func _note(time: float, start: float, pitch: float, decay: float) -> float:
	var age := time - start
	if age < 0.0:
		return 0.0
	var envelope := minf(age * 230.0, 1.0) * exp(-decay * age)
	return (sin(TAU * pitch * age) + 0.2 * sin(TAU * pitch * 2.0 * age)) * envelope


func _make_clip(cue: String, duration: float) -> AudioStreamWAV:
	var rng := RandomNumberGenerator.new()
	rng.seed = 8527
	var sample_count := ceili(duration * MIX_RATE)
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var low_noise := 0.0
	for i in range(sample_count):
		var t := float(i) / MIX_RATE
		var noise := rng.randf_range(-1.0, 1.0)
		low_noise = lerpf(low_noise, noise, 0.16)
		var sample := 0.0
		match cue:
			"shot":
				var string_ring := sin(TAU * (163.0 * t + 0.30 * (1.0 - exp(-55.0 * t))))
				sample = 0.61 * string_ring * exp(-25.0 * t) + 0.50 * noise * exp(-72.0 * t)
			"hit":
				sample = 0.68 * sin(TAU * 132.0 * t) * exp(-41.0 * t) + 0.68 * low_noise * exp(-42.0 * t)
			"miss", "branch":
				sample = low_noise * sin(PI * t / duration) * (0.9 if cue == "branch" else 0.36)
			"empty":
				sample = 0.5 * sin(TAU * 245.0 * t) * exp(-78.0 * t) + noise * 0.24 * exp(-95.0 * t)
			"target":
				sample = 0.36 * _note(t, 0, 784, 20) + 0.30 * _note(t, 0.08, 1047, 19)
			"event":
				sample = 0.38 * _note(t, 0, 659, 15) + 0.35 * _note(t, 0.12, 523, 13) + 0.29 * _note(t, 0.24, 392, 12)
			"spark":
				sample = 0.47 * noise * exp(-24 * t) + 0.28 * _note(t, 0.04, 1140, 25)
			"pickup":
				sample = 0.34 * _note(t, 0.0, 590.0, 29.0) + 0.29 * _note(t, 0.055, 815.0, 22.0)
			"buy":
				sample = 0.38 * _note(t, 0.0, 392.0, 17.0) + 0.35 * _note(t, 0.075, 493.9, 15.0) + 0.33 * _note(t, 0.15, 587.3, 12.0)
			"break":
				var cracks := exp(-50.0 * t) + 0.58 * exp(-50.0 * absf(t - 0.045))
				sample = 0.9 * low_noise * exp(-8.5 * t) + 0.45 * noise * cracks + 0.32 * sin(TAU * 69.0 * t) * exp(-11.0 * t)
			"win":
				sample = 0.34 * (_note(t, 0.0, 392.0, 6.0) + _note(t, 0.16, 493.9, 6.0) + _note(t, 0.32, 587.3, 6.0) + _note(t, 0.49, 784.0, 7.0))
		var fade := minf(t * 1100.0, 1.0) * minf((duration - t) * 200.0, 1.0)
		bytes.encode_s16(i * 2, roundi(clampf(sample * fade, -1.0, 1.0) * 32767.0))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = MIX_RATE
	clip.data = bytes
	return clip
