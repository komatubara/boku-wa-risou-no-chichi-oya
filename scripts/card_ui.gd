extends Control

signal swipe_confirmed(direction: int)  # -1=左スワイプ  +1=右スワイプ
signal flip_done()
signal swipe_preview(stat_changes: Dictionary)  # ドラッグ中：該当方向のstat_changesを通知
signal swipe_preview_cleared()                   # ドラッグ中断・リセット時

const SWIPE_THRESHOLD := 100.0
const CARD_W := 640.0
const CARD_H := 580.0
const CARD_X := 40.0   # (720 - 640) / 2
const CARD_Y := 200.0

const PHASE_BG := {
	"幼児": "res://assets/images/ui/card_bg_infant.png",
	"小学校": "res://assets/images/ui/card_bg_elementary.png",
	"中学校": "res://assets/images/ui/card_bg_junior_high.png",
	"高校": "res://assets/images/ui/card_bg_high_school.png",
	"社会人": "res://assets/images/ui/card_bg_adult.png",
}

var _card_panel: Panel
var _card_bg: TextureRect
var _char_image: TextureRect
var _event_label: Label
var _left_hint: Label
var _right_hint: Label

const IMAGE_H := 290.0  # カード上部のキャラクター画像エリア高さ

var _card_data: Dictionary = {}
var _drag_start: Vector2 = Vector2.ZERO
var _is_dragging: bool = false
var _is_animating: bool = false  # アニメーション中は入力を無視


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# カードパネル（透明・スワイプ変換の基準ノード）
	_card_panel = Panel.new()
	_card_panel.size = Vector2(CARD_W, CARD_H)
	_card_panel.position = Vector2(CARD_X, CARD_Y)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)  # 透明（背景はTextureRectで描画）
	_card_panel.add_theme_stylebox_override("panel", style)
	_card_panel.clip_contents = true  # 子ノードをカード内にクリップ
	add_child(_card_panel)

	# カード背景画像（フェーズ別ピクセルアート）
	_card_bg = TextureRect.new()
	_card_bg.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	_card_bg.stretch_mode = TextureRect.STRETCH_SCALE
	_card_bg.size = Vector2(CARD_W, CARD_H)
	_card_bg.position = Vector2(0, 0)
	_card_panel.add_child(_card_bg)

	# キャラクター画像（カード上部）
	_char_image = TextureRect.new()
	_char_image.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	_char_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_char_image.size = Vector2(CARD_W, IMAGE_H)
	_char_image.position = Vector2(0, 0)
	_card_panel.add_child(_char_image)

	# イベントテキスト（カード下部）
	_event_label = Label.new()
	_event_label.size = Vector2(CARD_W - 48, CARD_H - IMAGE_H - 16)
	_event_label.position = Vector2(24, IMAGE_H + 8)
	_event_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_event_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_event_label.add_theme_font_size_override("font_size", 24)
	_event_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.15))
	_card_panel.add_child(_event_label)

	# アクションヒント（スワイプ開始時のみ表示）
	_left_hint = Label.new()
	_left_hint.size = Vector2(340, 50)
	_left_hint.position = Vector2(10, CARD_Y + CARD_H + 20)
	_left_hint.add_theme_font_size_override("font_size", 22)
	_left_hint.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	_left_hint.visible = false
	add_child(_left_hint)

	_right_hint = Label.new()
	_right_hint.size = Vector2(340, 50)
	_right_hint.position = Vector2(370, CARD_Y + CARD_H + 20)
	_right_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_right_hint.add_theme_font_size_override("font_size", 22)
	_right_hint.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	_right_hint.visible = false
	add_child(_right_hint)


# 新しいカードデータを表示する（入力リセット含む）
func set_card(data: Dictionary) -> void:
	_card_data = data
	_event_label.text = data["event_text"]
	_left_hint.text = "◀ " + data["swipe_left"]["action_text"]
	_right_hint.text = data["swipe_right"]["action_text"] + " ▶"
	# カード背景: card_idで自動紐付け、なければフェーズ背景にフォールバック
	var card_id: String = data.get("card_id", "")
	var bg_path: String = "res://assets/images/ui/card_bgs/%s.png" % card_id
	if not ResourceLoader.exists(bg_path):
		bg_path = PHASE_BG.get(data.get("phase", ""), "")
	_card_bg.texture = load(bg_path) if bg_path != "" else null
	# キャラクター画像を読み込む
	var img_path: String = data.get("character_image", "")
	_char_image.texture = load(img_path) if img_path != "" else null
	_char_image.visible = _char_image.texture != null
	_card_panel.position = Vector2(CARD_X, CARD_Y)
	_card_panel.rotation = 0.0
	_card_panel.scale = Vector2.ONE
	_left_hint.visible = false
	_right_hint.visible = false
	_is_animating = false
	_is_dragging = false
	swipe_preview_cleared.emit()


func _input(event: InputEvent) -> void:
	if _is_animating:
		return

	# プレス開始
	if _is_press_start(event):
		var pos := _get_event_pos(event)
		if _card_panel.get_global_rect().has_point(pos):
			_drag_start = pos
			_is_dragging = true
			_left_hint.visible = true
			_right_hint.visible = true
		return

	# プレス終了
	if _is_press_end(event) and _is_dragging:
		_is_dragging = false
		var offset := _get_event_pos(event).x - _drag_start.x
		_on_drag_end(offset)
		return

	# ドラッグ中
	if _is_dragging and _is_motion(event):
		var offset := _get_event_pos(event).x - _drag_start.x
		_card_panel.position.x = CARD_X + offset
		_card_panel.rotation = offset * 0.0003  # わずかに傾ける
		# スワイプ方向が確定したらプレビュー表示
		if offset > 20:
			swipe_preview.emit(_card_data["swipe_right"]["stat_changes"])
		elif offset < -20:
			swipe_preview.emit(_card_data["swipe_left"]["stat_changes"])
		else:
			swipe_preview_cleared.emit()


func _is_press_start(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)


func _is_press_end(event: InputEvent) -> bool:
	return (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed) \
		or (event is InputEventScreenTouch and not event.pressed)


func _is_motion(event: InputEvent) -> bool:
	return event is InputEventMouseMotion or event is InputEventScreenDrag


func _get_event_pos(event: InputEvent) -> Vector2:
	return event.position


func _on_drag_end(offset: float) -> void:
	if abs(offset) >= SWIPE_THRESHOLD:
		_is_animating = true
		_left_hint.visible = false
		_right_hint.visible = false
		_animate_swipe_out(1 if offset > 0 else -1)
	else:
		_return_to_center()


func _return_to_center() -> void:
	_left_hint.visible = false
	_right_hint.visible = false
	swipe_preview_cleared.emit()
	var tw := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(_card_panel, "position:x", CARD_X, 0.4)
	tw.parallel().tween_property(_card_panel, "rotation", 0.0, 0.4)


func _animate_swipe_out(direction: int) -> void:
	var target_x := 820.0 if direction > 0 else -700.0
	var tw := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(_card_panel, "position:x", target_x, 0.2)
	await tw.finished
	swipe_confirmed.emit(direction)


# カードを反転させて result_text を表示する（_is_animating は set_card まで維持）
func flip_to_result(result_text: String) -> void:
	_is_animating = true
	swipe_preview_cleared.emit()
	# カードを中央に戻す
	_card_panel.position.x = CARD_X
	_card_panel.rotation = 0.0

	# 前半：scale.x を 1 → 0
	var tw1 := create_tween().set_trans(Tween.TRANS_SINE)
	tw1.tween_property(_card_panel, "scale:x", 0.0, 0.15)
	await tw1.finished

	# テキスト差し替え（scale=0 の瞬間）
	_event_label.text = result_text

	# 後半：scale.x を 0 → 1
	var tw2 := create_tween().set_trans(Tween.TRANS_SINE)
	tw2.tween_property(_card_panel, "scale:x", 1.0, 0.15)
	await tw2.finished

	flip_done.emit()
