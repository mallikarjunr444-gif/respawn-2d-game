extends Node

# ═══════════════════════════════════════════════════════════════
# SPACE ODYSSEY — Procedural Sound Synthesizer
# Generates native AudioStreamWAV samples with zero external deps.
# Includes rocket thrust, fuel pickup, low fuel warning, portal,
# ambient space, and all original combat sounds.
# ═══════════════════════════════════════════════════════════════

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var thrust_player: AudioStreamPlayer  # Continuous thrust loop
const MAX_PLAYERS = 16

var sounds: Dictionary = {}
var music_volume_db: float = -12.0
var sfx_volume_db: float = 0.0
var music_enabled: bool = true
var sfx_enabled: bool = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(MAX_PLAYERS):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

	music_player = AudioStreamPlayer.new()
	music_player.volume_db = music_volume_db
	music_player.bus = "Master"
	add_child(music_player)

	ambient_player = AudioStreamPlayer.new()
	ambient_player.volume_db = -18.0
	ambient_player.bus = "Master"
	add_child(ambient_player)

	thrust_player = AudioStreamPlayer.new()
	thrust_player.volume_db = -10.0
	thrust_player.bus = "Master"
	add_child(thrust_player)

	_bake_sounds()

func _bake_sounds() -> void:
	# ── Original combat sounds ──
	sounds["jump"] = _create_chirp(280.0, 620.0, 0.16, "sine")
	sounds["swing"] = _create_sweep(400.0, 120.0, 0.18, "sawtooth")
	sounds["shoot"] = _create_sweep(850.0, 220.0, 0.12, "square")
	sounds["lance"] = _create_dual_beam(180.0, 360.0, 0.45)
	sounds["hit"] = _create_hit(180.0, 45.0, 0.15)
	sounds["boom"] = _create_explosion(0.65)
	sounds["gem"] = _create_crystal_chime(1200.0, 0.28)
	sounds["shield"] = _create_bell(440.0, 0.8)
	sounds["click"] = _create_click(0.04)
	sounds["alert"] = _create_alert(0.25)
	sounds["heal"] = _create_heal(0.35)
	sounds["victory"] = _create_fanfare(0.8)
	sounds["dash"] = _create_noise_sweep(0.2, 500.0, 150.0)

	# ── New Space Odyssey sounds ──
	sounds["thrust"] = _create_thrust_loop(1.0)
	sounds["boost"] = _create_boost_ignition(0.35)
	sounds["fuel_pickup"] = _create_fuel_pickup(0.3)
	sounds["low_fuel"] = _create_low_fuel_warning(0.6)
	sounds["portal"] = _create_portal_activation(0.8)
	sounds["level_complete"] = _create_level_complete(1.2)
	sounds["gate_open"] = _create_gate_open(0.5)
	sounds["wind"] = _create_wind_ambience(2.0)
	sounds["collision"] = _create_collision(0.2)
	sounds["upgrade"] = _create_upgrade_sound(0.6)

func play(sfx_name: String, pitch_range: float = 0.08, vol_db: float = 0.0) -> void:
	if not sfx_enabled or not sounds.has(sfx_name):
		return
	var stream: AudioStreamWAV = sounds[sfx_name]
	var effective_vol = vol_db + sfx_volume_db
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = effective_vol
			p.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
			p.play()
			return
	# If all busy, reuse first player
	var fallback: AudioStreamPlayer = sfx_players[0]
	fallback.stream = stream
	fallback.volume_db = effective_vol
	fallback.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
	fallback.play()

func start_thrust_sound() -> void:
	if not sfx_enabled:
		return
	if not thrust_player.playing:
		thrust_player.stream = sounds.get("thrust")
		thrust_player.play()

func stop_thrust_sound() -> void:
	thrust_player.stop()

func set_music_volume(db: float) -> void:
	music_volume_db = db
	music_player.volume_db = db
	ambient_player.volume_db = db - 6.0

func set_sfx_volume(db: float) -> void:
	sfx_volume_db = db

func toggle_music(enabled: bool) -> void:
	music_enabled = enabled
	if not enabled:
		music_player.stop()
		ambient_player.stop()

func toggle_sfx(enabled: bool) -> void:
	sfx_enabled = enabled
	if not enabled:
		thrust_player.stop()
		for p in sfx_players:
			p.stop()

# ═══════════════════════════════════════════════════════════════
# AUDIO SYNTHESIS — 22050Hz 16-bit mono PCM
# ═══════════════════════════════════════════════════════════════

func _create_wav(data: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav

# ── Original synthesis methods ──

func _create_chirp(f_start: float, f_end: float, duration: float, type: String) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(f_start, f_end, t)
		phase += TAU * freq / float(sample_rate)
		var env: float = (1.0 - t) * sin(t * PI * 0.5)
		var val: float = 0.0
		if type == "sine":
			val = sin(phase)
		elif type == "square":
			val = 1.0 if sin(phase) > 0.0 else -1.0
		elif type == "sawtooth":
			val = fmod(phase / TAU, 1.0) * 2.0 - 1.0
		val *= env * 0.8
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_sweep(f_start: float, f_end: float, duration: float, type: String) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(f_start, f_end, t * t)
		phase += TAU * freq / float(sample_rate)
		var env: float = (1.0 - t)
		var val: float = sin(phase) if type == "sine" else (1.0 if sin(phase) > 0.0 else -1.0)
		val *= env * 0.7
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_hit(f_start: float, f_end: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(f_start, f_end, pow(t, 0.4))
		phase += TAU * freq / float(sample_rate)
		var env: float = pow(1.0 - t, 2.0)
		var noise: float = randf_range(-1.0, 1.0) * 0.3
		var val: float = (sin(phase) + noise) * env * 0.9
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_explosion(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	var filter_val: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var env: float = pow(1.0 - t, 1.5)
		phase += TAU * 60.0 / float(sample_rate)
		var raw: float = randf_range(-1.0, 1.0) * 0.7 + sin(phase) * 0.3
		filter_val = lerp(filter_val, raw, 0.25)
		var val: float = filter_val * env * 0.95
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_noise_sweep(duration: float, _f1: float, _f2: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var filtered: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var env: float = sin(t * PI)
		var raw: float = randf_range(-1.0, 1.0)
		filtered = lerp(filtered, raw, 0.2)
		var val: float = filtered * env * 0.7
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_crystal_chime(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var p1: float = 0.0
	var p2: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		p1 += TAU * freq / float(sample_rate)
		p2 += TAU * (freq * 1.5) / float(sample_rate)
		var env: float = pow(1.0 - t, 2.5)
		var val: float = (sin(p1) * 0.7 + sin(p2) * 0.3) * env * 0.8
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_bell(freq: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var p1: float = 0.0
	var p2: float = 0.0
	var p3: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		p1 += TAU * freq / float(sample_rate)
		p2 += TAU * (freq * 2.01) / float(sample_rate)
		p3 += TAU * (freq * 3.0) / float(sample_rate)
		var env: float = pow(1.0 - t, 2.0)
		var val: float = (sin(p1) * 0.5 + sin(p2) * 0.3 + sin(p3) * 0.2) * env * 0.75
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_click(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var val: float = sin(TAU * 1800.0 * float(i) / float(sample_rate)) * (1.0 - t) * 0.6
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_alert(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var f: float = 880.0 if t < 0.5 else 660.0
		phase += TAU * f / float(sample_rate)
		var val: float = sin(phase) * (1.0 - t * 0.5) * 0.6
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_dual_beam(f1: float, f2: float, duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var p1: float = 0.0
	var p2: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		p1 += TAU * f1 / float(sample_rate)
		p2 += TAU * f2 / float(sample_rate)
		var env: float = (1.0 - t) * sin(t * PI * 0.8)
		var val: float = (sin(p1) * 0.6 + sin(p2) * 0.4) * env * 0.85
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_heal(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var f: float = lerp(440.0, 880.0, t)
		phase += TAU * f / float(sample_rate)
		var val: float = sin(phase) * pow(1.0 - t, 0.5) * 0.65
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_fanfare(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var notes = [440.0, 554.37, 659.25, 880.0]
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var note_idx = int(clampf(t * 4.0, 0, 3))
		var f = notes[note_idx]
		phase += TAU * f / float(sample_rate)
		var val: float = sin(phase) * (1.0 - (t * 4.0 - note_idx) * 0.3) * (1.0 - t * 0.3) * 0.7
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

# ═══════════════════════════════════════════════════════════════
# NEW — Space Odyssey Sounds
# ═══════════════════════════════════════════════════════════════

func _create_thrust_loop(duration: float) -> AudioStreamWAV:
	## Low rumble + high hiss for continuous rocket thrust
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase_low: float = 0.0
	var filtered: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		# Low rumble oscillation
		phase_low += TAU * 55.0 / float(sample_rate)
		var rumble: float = sin(phase_low) * 0.4
		# High frequency hiss
		var hiss: float = randf_range(-1.0, 1.0) * 0.25
		filtered = lerp(filtered, hiss, 0.15)
		# Envelope: fade in/out for loop-ability
		var env: float = sin(t * PI)
		var val: float = (rumble + filtered) * env * 0.5
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	var wav = _create_wav(bytes, sample_rate)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = int(0.05 * sample_rate)
	wav.loop_end = samples - int(0.05 * sample_rate)
	return wav

func _create_boost_ignition(duration: float) -> AudioStreamWAV:
	## Sharp burst: rising tone + noise blast
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(200.0, 800.0, pow(t, 0.3))
		phase += TAU * freq / float(sample_rate)
		var env: float = pow(1.0 - t, 0.8) * (1.0 if t < 0.1 else 0.8)
		var val: float = (sin(phase) * 0.5 + randf_range(-1.0, 1.0) * 0.3) * env * 0.85
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_fuel_pickup(duration: float) -> AudioStreamWAV:
	## Ascending chime: three quick rising notes
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	var notes = [660.0, 880.0, 1100.0]
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var note_idx = int(clampf(t * 3.0, 0, 2))
		var freq = notes[note_idx]
		phase += TAU * freq / float(sample_rate)
		var local_t = t * 3.0 - note_idx
		var env: float = pow(1.0 - local_t, 1.5) * 0.8
		var val: float = sin(phase) * env
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_low_fuel_warning(duration: float) -> AudioStreamWAV:
	## Urgent two-tone beep-beep-beep
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var pulse = fmod(t * 6.0, 1.0)  # 6 pulses
		var env: float = 1.0 if pulse < 0.4 else 0.0  # On/off
		var freq: float = 920.0 if fmod(t * 3.0, 1.0) < 0.5 else 740.0
		phase += TAU * freq / float(sample_rate)
		var val: float = sin(phase) * env * 0.6
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_portal_activation(duration: float) -> AudioStreamWAV:
	## Sweeping ascending shimmer with harmonics
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var p1: float = 0.0
	var p2: float = 0.0
	var p3: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var f_base: float = lerp(220.0, 880.0, t)
		p1 += TAU * f_base / float(sample_rate)
		p2 += TAU * (f_base * 1.5) / float(sample_rate)
		p3 += TAU * (f_base * 2.0) / float(sample_rate)
		var env: float = sin(t * PI) * 0.8
		var val: float = (sin(p1) * 0.5 + sin(p2) * 0.3 + sin(p3) * 0.2) * env
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_level_complete(duration: float) -> AudioStreamWAV:
	## Triumphant ascending arpeggio
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var notes = [440.0, 554.37, 659.25, 783.99, 880.0, 1046.50]
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var note_idx = int(clampf(t * 6.0, 0, 5))
		var f = notes[note_idx]
		phase += TAU * f / float(sample_rate)
		var local_t = t * 6.0 - note_idx
		var env: float = pow(1.0 - local_t * 0.7, 1.5) * (1.0 - t * 0.2)
		var val: float = (sin(phase) * 0.6 + sin(phase * 2.01) * 0.3) * env * 0.75
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_gate_open(duration: float) -> AudioStreamWAV:
	## Mechanical hum rising to a bright ping
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(120.0, 1200.0, pow(t, 2.0))
		phase += TAU * freq / float(sample_rate)
		var env: float = sin(t * PI)
		var val: float = sin(phase) * env * 0.7
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_wind_ambience(duration: float) -> AudioStreamWAV:
	## Filtered noise with slow modulation for wind
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var filtered: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var raw: float = randf_range(-1.0, 1.0)
		var cutoff: float = 0.08 + sin(t * TAU * 0.5) * 0.04
		filtered = lerp(filtered, raw, cutoff)
		var env: float = sin(t * PI)
		var val: float = filtered * env * 0.4
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	var wav = _create_wav(bytes, sample_rate)
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = int(0.1 * sample_rate)
	wav.loop_end = samples - int(0.1 * sample_rate)
	return wav

func _create_collision(duration: float) -> AudioStreamWAV:
	## Metallic clang + crunch
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var phase: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var freq: float = lerp(400.0, 80.0, t)
		phase += TAU * freq / float(sample_rate)
		var env: float = pow(1.0 - t, 3.0)
		var metal: float = sin(phase) + sin(phase * 2.76) * 0.3
		var crunch: float = randf_range(-1.0, 1.0) * 0.4 * env
		var val: float = (metal * 0.6 + crunch) * env * 0.8
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)

func _create_upgrade_sound(duration: float) -> AudioStreamWAV:
	## Satisfying power-up: layered ascending shimmer
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	var p1: float = 0.0
	var p2: float = 0.0
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var f1: float = lerp(330.0, 660.0, t)
		var f2: float = lerp(440.0, 880.0, t)
		p1 += TAU * f1 / float(sample_rate)
		p2 += TAU * f2 / float(sample_rate)
		var env: float = sin(t * PI) * 0.85
		var val: float = (sin(p1) * 0.5 + sin(p2) * 0.5) * env
		bytes.encode_s16(i * 2, int(clampf(val, -1.0, 1.0) * 32767.0))
	return _create_wav(bytes, sample_rate)
