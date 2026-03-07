extends Control


func _ready() -> void:
	BgmManager.stop_bgm()
	_build_ui()


func _build_ui() -> void:
	var ending: Dictionary = CardManager.get_ending(GameState.pending_ending_id)
	if ending.is_empty():
		push_error("Ending: invalid ending_id: " + GameState.pending_ending_id)
		return

	# 背景（フォールバック用の単色）
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# エンディング別背景イラスト
	var bg_tex := load("res://assets/images/endings/%s.png" % GameState.pending_ending_id)
	if bg_tex:
		var bg_img := TextureRect.new()
		bg_img.texture = bg_tex
		bg_img.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		bg_img.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(bg_img)

	# 半透明オーバーレイ（テキスト可読性確保）
	var overlay := ColorRect.new()
	overlay.color = Color(0.0, 0.0, 0.05, 0.55)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	# タグライン（🧠 自立心 ゼロ など）
	var tagline := Label.new()
	tagline.text = ending.get("tagline", "")
	tagline.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tagline.add_theme_font_size_override("font_size", 20)
	tagline.add_theme_color_override("font_color", Color(0.6, 0.6, 0.75))
	tagline.size = Vector2(680, 40)
	tagline.position = Vector2(20, 60)
	add_child(tagline)

	# エンディングタイトル
	var title_lbl := Label.new()
	title_lbl.text = ending.get("title", "")
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 44)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_lbl.size = Vector2(680, 90)
	title_lbl.position = Vector2(20, 110)
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(title_lbl)

	# 本文（ScrollContainerで高さを制限）
	var scroll := ScrollContainer.new()
	scroll.size = Vector2(660, 620)
	scroll.position = Vector2(30, 230)
	add_child(scroll)

	var body := Label.new()
	body.text = ending.get("body_text", "")
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(640, 0)
	scroll.add_child(body)

	# 「もう一度」ボタン
	var btn := Button.new()
	btn.text = "もう一度"
	btn.size = Vector2(400, 80)
	btn.position = Vector2(160, 1080)
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(_on_retry_pressed)
	add_child(btn)


func _on_retry_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/title.tscn")
