extends Control


func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# カード風パネル
	var card := Panel.new()
	card.size = Vector2(640, 380)
	card.position = Vector2(40, 390)
	add_child(card)

	# フェーズ名
	var phase_lbl := Label.new()
	phase_lbl.text = GameState.PHASES[GameState.current_phase]
	phase_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	phase_lbl.add_theme_font_size_override("font_size", 56)
	phase_lbl.add_theme_color_override("font_color", Color.WHITE)
	phase_lbl.size = Vector2(580, 130)
	phase_lbl.position = Vector2(30, 80)
	phase_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(phase_lbl)

	# 息子の年齢
	var age_lbl := Label.new()
	age_lbl.text = "息子 " + str(GameState.PHASE_AGES[GameState.current_phase]) + "歳"
	age_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	age_lbl.add_theme_font_size_override("font_size", 32)
	age_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.95))
	age_lbl.size = Vector2(580, 80)
	age_lbl.position = Vector2(30, 240)
	card.add_child(age_lbl)

	# タップ誘導
	var hint := Label.new()
	hint.text = "タップして続ける"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 20)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.65))
	hint.size = Vector2(680, 40)
	hint.position = Vector2(20, 1200)
	add_child(hint)


func _input(event: InputEvent) -> void:
	var tapped: bool = (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed) \
		or (event is InputEventScreenTouch and event.pressed)
	if tapped:
		get_tree().change_scene_to_file("res://scenes/game.tscn")
