extends Node

# Procedural Sound Synthesizer for Event Horizon
# Generates native AudioStreamWAV samples on initialization with zero external dependencies.

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
const MAX_PLAYERS = 16

var sounds: Dictionary = {}
var muted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(MAX_PLAYERS):
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
		
	music_player = AudioStreamPlayer.new()
	music_player.volume_db = -12.0
	add_child(music_player)
	
	_bake_sounds()

func _bake_sounds() -> void:
	sounds["jump"] = _create_chirp(280.0, 620.0, 0.16, "sine")
	sounds["dash"] = _create_noise_sweep(0.2, 500.0, 150.0)
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

func toggle_mute() -> void:
	muted = not muted
	AudioServer.set_bus_mute(0, muted)

func play(sfx_name: String, pitch_range: float = 0.08, vol_db: float = 0.0) -> void:
	if muted:
		return
	if not sounds.has(sfx_name):
		return
	var stream: AudioStreamWAV = sounds[sfx_name]
	for p in sfx_players:
		if not p.playing:
			p.stream = stream
			p.volume_db = vol_db
			p.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
			p.play()
			return
	# If all busy, reuse first player
	var fallback: AudioStreamPlayer = sfx_players[0]
	fallback.stream = stream
	fallback.volume_db = vol_db
	fallback.pitch_scale = randf_range(1.0 - pitch_range, 1.0 + pitch_range)
	fallback.play()

# Audio synthesis helpers producing 22050Hz 16-bit mono PCM AudioStreamWAV
func _create_wav(data: PackedByteArray, sample_rate: int = 22050) -> AudioStreamWAV:
	var wav = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav

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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
		
	return _create_wav(bytes, sample_rate)

func _create_click(duration: float) -> AudioStreamWAV:
	var sample_rate: int = 22050
	var samples: int = int(duration * sample_rate)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples * 2)
	for i in range(samples):
		var t: float = float(i) / float(samples)
		var val: float = sin(TAU * 1800.0 * float(i) / float(sample_rate)) * (1.0 - t) * 0.6
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
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
		var s16: int = int(clampf(val, -1.0, 1.0) * 32767.0)
		bytes.encode_s16(i * 2, s16)
	return _create_wav(bytes, sample_rate)
