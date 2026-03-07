extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var seen: Array[String] = GameState.get_seen_endings()

	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# タイトル
	var title_lbl := Label.new()
	title_lbl.text = "エンディング一覧"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 36)
	title_lbl.add_theme_color_override("font_color", Color.WHITE)
	title_lbl.size = Vector2(680, 60)
	title_lbl.position = Vector2(20, 30)
	add_child(title_lbl)

	# 進捗表示
	var progress := Label.new()
	progress.text = "%d / 7 クリア" % seen.size()
	progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_theme_font_size_override("font_size", 18)
	progress.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	progress.size = Vector2(680, 32)
	progress.position = Vector2(20, 82)
	add_child(progress)

	# スクロールコンテナ
	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.0
	scroll.anchor_right = 1.0
	scroll.anchor_top = 0.0
	scroll.anchor_bottom = 1.0
	scroll.offset_top = 126
	scroll.offset_bottom = -120
	scroll.offset_left = 20
	scroll.offset_right = -20
	add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(660, 0)
	scroll.add_child(vbox)

	for ending in CardManager.load_all_endings():
		var ending_id: String = ending.get("ending_id", "")
		vbox.add_child(_build_card(ending, ending_id in seen))

	# もどるボタン
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


func _build_card(ending: Dictionary, is_seen: bool) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(0, 96)

	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(6)
	style.set_border_width_all(1)
	if is_seen:
		style.bg_color = Color(0.14, 0.14, 0.22)
		style.border_color = Color(0.45, 0.45, 0.7)
	else:
		style.bg_color = Color(0.08, 0.08, 0.11)
		style.border_color = Color(0.2, 0.2, 0.28)
	panel.add_theme_stylebox_override("panel", style)

	# タイトル（未見は「？？？」）
	var title_lbl := Label.new()
	title_lbl.text = ending.get("title", "") if is_seen else "？？？"
	title_lbl.add_theme_font_size_override("font_size", 26)
	title_lbl.add_theme_color_override("font_color",
		Color.WHITE if is_seen else Color(0.35, 0.35, 0.42))
	title_lbl.position = Vector2(16, 10)
	title_lbl.size = Vector2(550, 40)
	panel.add_child(title_lbl)

	# タグライン（解放条件は常に表示）
	var tag_lbl := Label.new()
	tag_lbl.text = ending.get("tagline", "")
	tag_lbl.add_theme_font_size_override("font_size", 15)
	tag_lbl.add_theme_color_override("font_color",
		Color(0.6, 0.6, 0.78) if is_seen else Color(0.38, 0.38, 0.46))
	tag_lbl.position = Vector2(16, 56)
	tag_lbl.size = Vector2(550, 28)
	panel.add_child(tag_lbl)

	# 済バッジ
	if is_seen:
		var badge := Label.new()
		badge.text = "済"
		badge.add_theme_font_size_override("font_size", 20)
		badge.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.position = Vector2(610, 32)
		badge.size = Vector2(40, 32)
		panel.add_child(badge)

	return panel
