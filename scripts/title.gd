extends Control


func _ready() -> void:
	_build_bg()
	_build_father()
	_build_title()
	_build_buttons()
	BgmManager.stop_bgm()


func _build_bg() -> void:
	# 背景画像（居間・ピクセルアート）
	var bg_tex := load("res://assets/images/ui/title_bg.png")
	if bg_tex:
		var bg := TextureRect.new()
		bg.texture = bg_tex
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(bg)
	# 半透明オーバーレイ（テキスト可読性確保）
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.05, 0.45)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)


func _build_father() -> void:
	pass  # タイトル画面では父キャラ非表示


func _build_title() -> void:
	# 筆文字ロゴ装飾
	var logo_tex := load("res://assets/images/ui/title_logo.png")
	if logo_tex:
		var logo := TextureRect.new()
		logo.texture = logo_tex
		logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		logo.size = Vector2(640, 160)
		logo.position = Vector2(40, 30)
		add_child(logo)

	var lbl := Label.new()
	lbl.text = "ぼくはりそうのちちおや"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 42)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.size = Vector2(680, 120)
	lbl.position = Vector2(20, 200)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(lbl)

	var sub := Label.new()
	sub.text = "〜りそうのちちおや育成シミュレーション〜"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.9, 0.85, 0.6))
	sub.size = Vector2(680, 40)
	sub.position = Vector2(20, 340)
	add_child(sub)


func _build_buttons() -> void:
	var start := Button.new()
	start.text = "はじめる"
	start.size = Vector2(400, 80)
	start.position = Vector2(160, 700)
	start.add_theme_font_size_override("font_size", 28)
	start.pressed.connect(_on_start_pressed)
	add_child(start)

	var help := Button.new()
	help.text = "あそびかた"
	help.size = Vector2(400, 80)
	help.position = Vector2(160, 810)
	help.add_theme_font_size_override("font_size", 28)
	help.pressed.connect(_on_help_pressed)
	add_child(help)


func _on_start_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
