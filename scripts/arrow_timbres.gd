extends RefCounted
## Stable settings IDs, bilingual names and level trims for the private audio test.

const SHOT := "shot_timbre"
const IMPACT := "impact_timbre"
const DEFAULT_SHOT := "recorded_dry"
const DEFAULT_IMPACT := "recorded_deep"
const CATALOG := {
	SHOT: {
		"recorded_dry": ["Suelta seca · grabación", "Dry release · recording", preload("res://assets/audio/freesound/suelta_seca.wav"), 0.0],
		"recorded_fiber": ["Cuerda y fibra · grabación", "String and fiber · recording", preload("res://assets/audio/freesound/suelta_fibra.wav"), -6.0],
		"short": ["Cuerda corta", "Short string", null, 0.0],
		"resonant": ["Cuerda resonante", "Resonant string", null, 0.0],
		"original": ["Original de la demo", "Demo original", null, -6.0],
	},
	IMPACT: {
		"recorded_dry": ["Golpe seco · grabación", "Dry knock · recording", preload("res://assets/audio/freesound/impacto_seco.wav"), 3.0],
		"recorded_deep": ["Golpe grave · grabación", "Deep thud · recording", preload("res://assets/audio/freesound/impacto_grave.wav"), -3.5],
		"wood": ["Madera seca", "Dry timber", null, 0.0],
		"crack": ["Tronco con crujido", "Cracking trunk", null, 0.0],
		"original": ["Original de la demo", "Demo original", null, -4.5],
	},
}

static func selected(setting: String, value: Variant) -> String:
	if value is String and CATALOG[setting].has(value):
		return value
	return DEFAULT_SHOT if setting == SHOT else DEFAULT_IMPACT

# A short, damped string and a struck piece of wood each keep their own noise envelope.
static func synthesize(setting: String, id: String) -> AudioStreamWAV:
	const RATE := 22050
	var rng := RandomNumberGenerator.new()
	rng.seed = 3407 if setting == SHOT else 8179
	var string_delay := PackedFloat32Array()
	string_delay.resize(106 if id == "short" else 149)
	for i in string_delay.size():
		string_delay[i] = rng.randf_range(-1.0, 1.0)
	var duration := 0.36 if id in ["crack", "resonant"] else 0.19
	var frames := ceili(duration * RATE)
	var samples := PackedFloat32Array()
	samples.resize(frames)
	var filtered_noise := 0.0
	var peak := 0.0
	var energy := 0.0
	var window_frames := roundi(RATE * 0.05)
	var loudest_window := 0.0
	for i in frames:
		var t := float(i) / RATE
		var noise := rng.randf_range(-1, 1)
		filtered_noise = lerpf(filtered_noise, noise, 0.24)
		var sample := 0.0
		if setting == SHOT:
			var slot := i % string_delay.size()
			var vibration := string_delay[slot]
			var neighbor := string_delay[(slot + 1) % string_delay.size()]
			string_delay[slot] = lerpf(vibration, neighbor, 0.58) * (0.88 if id == "short" else 0.955)
			sample = (vibration * 0.52 + filtered_noise * exp(-70.0 * t)) * minf(t * 1200.0, 1.0)
			sample += 0.19 * sin(TAU * 137.0 * t) * exp(-44.0 * t)
		else:
			var pitch := 176.0 if id == "wood" else 84.0
			sample = 0.35 * sin(TAU * pitch * t) * exp(-32.0 * t)
			sample += 0.17 * sin(TAU * pitch * 2.63 * t) * exp(-68.0 * t)
			sample += (noise * 0.52 + filtered_noise * 0.75) * exp(-162.0 * t)
			if id == "crack":
				for onset: float in [0.021, 0.049, 0.083, 0.122]:
					if t >= onset:
						sample += (noise + filtered_noise) * 0.29 * exp(-158.0 * (t - onset) - 9.0 * onset)
		sample *= clampf(t * 1900.0, 0.0, 1.0) * clampf((duration - t) * 120.0, 0.0, 1.0)
		samples[i] = sample
		peak = maxf(peak, absf(sample))
		energy += sample * sample
		if i >= window_frames:
			energy -= samples[i - window_frames] * samples[i - window_frames]
		loudest_window = maxf(loudest_window, energy)
	# Match the recordings near -20 dBFS RMS over their loudest 50 ms; keep headroom.
	var gain := minf(0.95 / maxf(peak, 0.001), 0.1 / sqrt(maxf(loudest_window / window_frames, 0.00001)))
	var pcm := PackedByteArray()
	pcm.resize(frames * 2)
	for i in frames:
		pcm.encode_s16(i * 2, roundi(samples[i] * gain * 32767))
	var clip := AudioStreamWAV.new()
	clip.format = AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate = RATE
	clip.data = pcm
	return clip
