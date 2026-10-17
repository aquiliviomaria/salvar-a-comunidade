extends Node

const SAMPLE_RATE: float = 22050.0


func play_ui() -> void:
	_play_tone(660.0, 0.06, 0.10)


func play_success() -> void:
	_play_tone(880.0, 0.11, 0.14)
	_play_tone(1175.0, 0.13, 0.11)


func play_collect() -> void:
	_play_tone(520.0, 0.08, 0.09)


func play_build() -> void:
	_play_tone(260.0, 0.08, 0.14)
	_play_tone(340.0, 0.08, 0.12)


func play_cut() -> void:
	_play_tone(180.0, 0.10, 0.16)


func play_error() -> void:
	_play_tone(150.0, 0.12, 0.12)


func _play_tone(frequency: float, duration: float, volume: float) -> void:
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = SAMPLE_RATE
	stream.buffer_length = max(duration + 0.05, 0.15)
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()
	var playback := player.get_stream_playback() as AudioStreamGeneratorPlayback
	var frames: int = int(SAMPLE_RATE * duration)
	for index: int in range(frames):
		var t: float = float(index) / SAMPLE_RATE
		var fade: float = 1.0 - (float(index) / float(max(frames, 1)))
		var sample: float = sin(TAU * frequency * t) * volume * fade
		playback.push_frame(Vector2(sample, sample))
	await get_tree().create_timer(duration + 0.05).timeout
	player.queue_free()
