extends Node

const BGM_VOLUME_DB := -15.0  # BGM音量（0.0=最大、-10.0=約1/3の音量感）

const BGM_PATHS: Array[String] = [
	"res://assets/audio/bgm_infant.mp3",
	"res://assets/audio/bgm_elementary.mp3",
	"res://assets/audio/bgm_junior_high.mp3",
	"res://assets/audio/bgm_high_school.mp3",
	"res://assets/audio/bgm_adult.mp3",
]

var _player: AudioStreamPlayer
var _current_phase: int = -1


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.volume_db = BGM_VOLUME_DB
	add_child(_player)


# 指定フェーズのBGMを再生（同フェーズ再生中はスキップ）
func play_phase(phase_idx: int) -> void:
	if phase_idx == _current_phase and _player.playing:
		return
	_current_phase = phase_idx
	var stream: AudioStream = load(BGM_PATHS[phase_idx])
	if stream == null:
		push_error("BgmManager: file not found: " + BGM_PATHS[phase_idx])
		return
	_player.stream = stream
	_player.volume_db = BGM_VOLUME_DB
	_player.play()


# BGMをフェードアウトして停止
func stop_bgm(fade_sec: float = 0.5) -> void:
	if not _player.playing:
		return
	_current_phase = -1
	var tw := create_tween()
	tw.tween_property(_player, "volume_db", -60.0, fade_sec)
	tw.tween_callback(_player.stop)
	tw.tween_callback(_reset_volume)


func _reset_volume() -> void:
	_player.volume_db = BGM_VOLUME_DB
