extends Control

var _cards: Array = []
var _card_ui: Control       # card_ui.gd インスタンス
var _param_icons: Control   # param_icons.gd インスタンス
var _is_transitioning: bool = false  # シーン遷移中フラグ（2重遷移防止）


func _ready() -> void:
	_setup_bg()
	_setup_param_icons()
	_setup_card_ui()
	_connect_signals()
	_load_and_show_card()
	BgmManager.play_phase(GameState.current_phase)


func _setup_bg() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)


func _setup_param_icons() -> void:
	_param_icons = Control.new()
	_param_icons.set_script(load("res://scripts/param_icons.gd"))
	_param_icons.size = Vector2(720, 120)
	_param_icons.position = Vector2(0, 20)
	add_child(_param_icons)


func _setup_card_ui() -> void:
	_card_ui = Control.new()
	_card_ui.set_script(load("res://scripts/card_ui.gd"))
	_card_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_card_ui)
	_card_ui.swipe_confirmed.connect(_on_swipe_confirmed)
	_card_ui.flip_done.connect(_on_flip_done)
	_card_ui.swipe_preview.connect(_param_icons.show_preview)
	_card_ui.swipe_preview_cleared.connect(_param_icons.clear_preview)


func _connect_signals() -> void:
	GameState.bad_end_triggered.connect(_on_bad_end)
	GameState.phase_cleared.connect(_on_phase_cleared)
	GameState.param_changed.connect(_on_param_changed)


func _load_and_show_card() -> void:
	_cards = CardManager.load_cards(GameState.current_phase)
	_card_ui.set_card(_cards[GameState.card_index])
	_param_icons.refresh()


# スワイプが確定したときの処理
func _on_swipe_confirmed(direction: int) -> void:
	var swipe_key := "swipe_left" if direction < 0 else "swipe_right"
	var swipe_data: Dictionary = _cards[GameState.card_index][swipe_key]
	GameState.apply_changes(swipe_data["stat_changes"])
	_card_ui.flip_to_result(swipe_data["result_text"])


# カード反転アニメーション完了後：2.5秒待って次へ進む
func _on_flip_done() -> void:
	await get_tree().create_timer(2.5).timeout
	if _is_transitioning:
		return
	GameState.advance_card()
	# advance_card() 内で bad_end_triggered / phase_cleared が emit された場合は
	# _is_transitioning が true になるので、それ以外（同フェーズ内の次カード）は
	# ここで次のカードを表示する
	if not _is_transitioning:
		_load_and_show_card()


func _on_bad_end(ending_id: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	GameState.pending_ending_id = ending_id
	get_tree().change_scene_to_file("res://scenes/ending.tscn")


func _on_phase_cleared(_next_phase: int) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	get_tree().change_scene_to_file("res://scenes/phase_transition.tscn")


func _on_param_changed(_key: String, _val: int) -> void:
	_param_icons.refresh()
