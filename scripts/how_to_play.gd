extends Control

const PARAM_KEYS: Array[String] = ["independence", "ego", "wealth", "hate"]
const PARAM_NAMES: Array[String] = ["自立心", "ワガママ度", "親の財力", "世間のヘイト"]
const PARAM_DANGERS: Array[String] = [
	"0→ニートエンド\n100→巣立ちエンド",
	"0→人形エンド\n100→犯罪者エンド",
	"0→自己破産エンド",
	"100→炎上エンド",
]
const ICON_PATHS: Dictionary = {
	"independence": "res://assets/images/icons/icon_independence.png",
	"ego":          "res://assets/images/icons/icon_ego.png",
	"wealth":       "res://assets/images/icons/icon_wealth.png",
	"hate":         "res://assets/images/icons/icon_hate.png",
}

var _left_hint: Label
var _right_hint: Label


func _ready() -> void:
	var safe_top: float = DisplayServer.get_display_safe_area().position.y

	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# タイトル
	var title := Label.new()
	title.text = "あそびかた"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size = Vector2(680, 60)
	title.position = Vector2(20, 30 + safe_top)
	add_child(title)

	var y := 110.0 + safe_top

	# ミニカードプレビュー（640×320）
	var card_frame := Panel.new()
	card_frame.size = Vector2(640, 320)
	card_frame.position = Vector2(40, y)
	card_frame.clip_contents = true
	var card_style := StyleBoxFlat.new()
	card_style.bg_color = Color(0.95, 0.91, 0.78)
	card_frame.add_theme_stylebox_override("panel", card_style)
	add_child(card_frame)

	var bg_tex := load("res://assets/images/ui/card_bgs/inf_01.png")
	if bg_tex:
		var card_bg := TextureRect.new()
		card_bg.texture = bg_tex
		card_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		card_bg.size = Vector2(640, 320)
		card_frame.add_child(card_bg)

	var char_tex := load("res://assets/images/cards/infant/inf_01.png")
	if char_tex:
		var char_img := TextureRect.new()
		char_img.texture = char_tex
		char_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		char_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		char_img.size = Vector2(640, 320)
		card_frame.add_child(char_img)

	y += 330.0

	# スワイプヒントラベル（交互フェードアニメーション）
	_left_hint = Label.new()
	_left_hint.text = "◀  まともな対応"
	_left_hint.size = Vector2(320, 50)
	_left_hint.position = Vector2(20, y)
	_left_hint.add_theme_font_size_override("font_size", 22)
	_left_hint.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
	_left_hint.modulate.a = 0.0
	add_child(_left_hint)

	_right_hint = Label.new()
	_right_hint.text = "モンペ対応  ▶"
	_right_hint.size = Vector2(320, 50)
	_right_hint.position = Vector2(380, y)
	_right_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_right_hint.add_theme_font_size_override("font_size", 22)
	_right_hint.add_theme_color_override("font_color", Color(1.0, 0.5, 0.4))
	_right_hint.modulate.a = 0.0
	add_child(_right_hint)

	_start_swipe_animation()

	y += 70.0

	# セパレーター
	_add_separator(y)
	y += 16.0

	# パラメーターセクション
	var param_header := Label.new()
	param_header.text = "【パラメーター】"
	param_header.add_theme_font_size_override("font_size", 22)
	param_header.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	param_header.size = Vector2(680, 36)
	param_header.position = Vector2(20, y)
	add_child(param_header)

	y += 44.0

	var col_w := 170.0
	for i in range(4):
		var key: String = PARAM_KEYS[i]
		var col_x: float = 20.0 + i * col_w

		var icon_tex := load(ICON_PATHS[key])
		if icon_tex:
			var icon := TextureRect.new()
			icon.texture = icon_tex
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.size = Vector2(48, 48)
			icon.position = Vector2(col_x + (col_w - 48) / 2.0, y)
			add_child(icon)

		var name_lbl := Label.new()
		name_lbl.text = PARAM_NAMES[i]
		name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_lbl.add_theme_font_size_override("font_size", 16)
		name_lbl.add_theme_color_override("font_color", Color.WHITE)
		name_lbl.size = Vector2(col_w - 10, 28)
		name_lbl.position = Vector2(col_x + 5, y + 52)
		add_child(name_lbl)

		var danger_lbl := Label.new()
		danger_lbl.text = PARAM_DANGERS[i]
		danger_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		danger_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		danger_lbl.add_theme_font_size_override("font_size", 13)
		danger_lbl.add_theme_color_override("font_color", Color(1.0, 0.6, 0.6))
		danger_lbl.size = Vector2(col_w - 10, 56)
		danger_lbl.position = Vector2(col_x + 5, y + 83)
		add_child(danger_lbl)

	y += 150.0

	# もどるボタン（画面下部にアンカー固定）
	var back := Button.new()
	back.anchor_left = 0.5
	back.anchor_right = 0.5
	back.anchor_top = 1.0
	back.anchor_bottom = 1.0
	back.offset_left = -200
	back.offset_right = 200
	back.offset_top = -100
	back.offset_bottom = -20
	back.text = "もどる"
	back.add_theme_font_size_override("font_size", 28)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/title.tscn"))
	add_child(back)


func _add_separator(y: float) -> void:
	var sep := ColorRect.new()
	sep.color = Color(0.3, 0.3, 0.4)
	sep.size = Vector2(640, 1)
	sep.position = Vector2(40, y)
	add_child(sep)


func _start_swipe_animation() -> void:
	var tw := create_tween().set_loops()
	tw.tween_property(_left_hint,  "modulate:a", 1.0, 0.4)
	tw.tween_interval(0.8)
	tw.tween_property(_left_hint,  "modulate:a", 0.0, 0.4)
	tw.tween_interval(0.2)
	tw.tween_property(_right_hint, "modulate:a", 1.0, 0.4)
	tw.tween_interval(0.8)
	tw.tween_property(_right_hint, "modulate:a", 0.0, 0.4)
	tw.tween_interval(0.2)
