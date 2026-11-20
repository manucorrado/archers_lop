extends Node

# Small original sounds generated once. All voices may overlap the bowstring.
const MIX_RATE := 22050
const LENGTHS := {
	"shot": 0.21, "hit": 0.15, "miss": 0.08, "empty": 0.09,
	"pickup": 0.24, "buy": 0.43, "break": 0.43, "win": 0.95, "branch": 0.14,
}
var _voices: Dictionary = {}


func _ready() -> void:
	for cue: String in LENGTHS:
		var voice := AudioStreamPlayer.new()
		voice.stream = _make_clip(cue, LENGTHS[cue])
		if cue == "buy" or cue == "win":
			voice.process_mode = Node.PROCESS_MODE_ALWAYS
		# The short, pitched workshop and purchase cues read above the wood impacts.
		match cue:
			"pickup": voice.volume_db = -7.0
			"buy": voice.volume_db = -8.0
			_: voice.volume_db = -10.0
		voice.max_polyphony = 2
		add_child(voice)
		_voices[cue] = voice


func play(cue: String) -> void:
	var voice: AudioStreamPlayer = _voices.get(cue)
	if voice != null:
		voice.play()


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
