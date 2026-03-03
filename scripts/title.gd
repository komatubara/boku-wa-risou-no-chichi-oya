extends Control


func _ready() -> void:
	_build_bg()
	_build_father()
	_build_title()
	_build_buttons()


func _build_bg() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)


func _build_father() -> void:
	var tex := load("res://assets/images/characters/father.png")
	if tex == null:
		return
	var rect := TextureRect.new()
	rect.texture = tex
	rect.expand_mode = TextureRect.EXPAND_KEEP_ASPECT
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.size = Vector2(300, 300)
	rect.position = Vector2(210, 560)
	add_child(rect)


func _build_title() -> void:
	var lbl := Label.new()
	lbl.text = "ぼくはりそうのちちおや"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 42)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	lbl.size = Vector2(680, 120)
	lbl.position = Vector2(20, 80)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(lbl)

	var sub := Label.new()
	sub.text = "〜りそうのちちおや育成シミュレーション〜"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 18)
	sub.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9))
	sub.size = Vector2(680, 40)
	sub.position = Vector2(20, 220)
	add_child(sub)


func _build_buttons() -> void:
	var start := Button.new()
	start.text = "はじめる"
	start.size = Vector2(400, 80)
	start.position = Vector2(160, 900)
	start.add_theme_font_size_override("font_size", 28)
	start.pressed.connect(_on_start_pressed)
	add_child(start)

	var help := Button.new()
	help.text = "あそびかた"
	help.size = Vector2(400, 80)
	help.position = Vector2(160, 1020)
	help.add_theme_font_size_override("font_size", 28)
	help.pressed.connect(_on_help_pressed)
	add_child(help)


func _on_start_pressed() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_help_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to_play.tscn")
