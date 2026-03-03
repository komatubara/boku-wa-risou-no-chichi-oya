extends Control


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.08, 0.12)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var title := Label.new()
	title.text = "あそびかた"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.size = Vector2(680, 60)
	title.position = Vector2(20, 60)
	add_child(title)

	var body := Label.new()
	body.text = (
		"◀ 左スワイプ：まともな対応\n"
		+ "　息子を見守り、自立を促す親らしい選択。\n\n"
		+ "▶ 右スワイプ：モンペ対応\n"
		+ "　「りそうのちちおや」として過剰に介入。\n"
		+ "　息子がどんどんダメになっていく。\n\n"
		+ "【パラメーター】\n"
		+ "🧠 自立心が   0 → ニートエンド\n"
		+ "👑 ワガママ度が 100 → 犯罪者エンド\n"
		+ "💰 親の財力が  0 → 自己破産エンド\n"
		+ "👁 世間のヘイトが 100 → 炎上エンド\n\n"
		+ "いずれかのパラメーターが限界に達すると\n"
		+ "ゲームオーバー。全エンドを見てみよう！"
	)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 22)
	body.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	body.size = Vector2(660, 900)
	body.position = Vector2(30, 160)
	add_child(body)

	var back := Button.new()
	back.text = "もどる"
	back.size = Vector2(400, 80)
	back.position = Vector2(160, 1140)
	back.add_theme_font_size_override("font_size", 28)
	back.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/title.tscn"))
	add_child(back)
