extends Control


func _ready() -> void:
	# セーフエリア対応：トップ余白を取得（Web では 0）
	var safe_top: float = DisplayServer.get_display_safe_area().position.y

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
	title.position = Vector2(20, 60 + safe_top)
	add_child(title)

	# 本文：ScrollContainerでアンカー固定（タイトル直下〜ボタン直上）
	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.0
	scroll.anchor_right = 1.0
	scroll.anchor_top = 0.0
	scroll.anchor_bottom = 1.0
	scroll.offset_top = 140 + safe_top
	scroll.offset_bottom = -120
	scroll.offset_left = 30
	scroll.offset_right = -30
	add_child(scroll)

	var body := Label.new()
	body.text = (
		"◀ 左スワイプ：まともな対応\n"
		+ "　息子を見守り、自立を促す親らしい選択。\n\n"
		+ "▶ 右スワイプ：モンペ対応\n"
		+ "　「りそうのちちおや」として過剰に介入。\n"
		+ "　息子がどんどんダメになっていく。\n\n"
		+ "【パラメーター】\n"
		+ "🧠 自立心が   0 → ニートエンド\n"
		+ "🧠 自立心が 100 → 巣立ちエンド\n"
		+ "👑 ワガママ度が   0 → 人形エンド\n"
		+ "👑 ワガママ度が 100 → 犯罪者エンド\n"
		+ "💰 親の財力が   0 → 自己破産エンド\n"
		+ "👁 世間のヘイトが 100 → 炎上エンド\n\n"
		+ "パラメーターが限界に達するとゲームオーバー。\n"
		+ "全7エンドを見てみよう！"
	)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 22)
	body.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	body.custom_minimum_size = Vector2(660, 0)
	scroll.add_child(body)

	# ボタンを画面下部にアンカー固定
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
