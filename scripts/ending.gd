extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var ending: Dictionary = CardManager.get_ending(GameState.pending_ending_id)
	if ending.is_empty():
		push_error("Ending: invalid ending_id: " + GameState.pending_ending_id)
		return

	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

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

	# 本文
	var body := Label.new()
	body.text = ending.get("body_text", "")
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.add_theme_font_size_override("font_size", 20)
	body.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	body.size = Vector2(640, 420)
	body.position = Vector2(40, 230)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(body)

	# 父キャラクター立ち絵
	var tex := load("res://assets/images/characters/father.png")
	if tex:
		var rect := TextureRect.new()
		rect.texture = tex
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.size = Vector2(220, 220)
		rect.position = Vector2(250, 700)
		add_child(rect)

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
