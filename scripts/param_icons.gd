extends Control

const PARAM_KEYS: Array[String] = ["independence", "ego", "wealth", "hate"]
const ICON_PATHS: Dictionary = {
	"independence": "res://assets/images/icons/icon_independence.png",
	"ego":          "res://assets/images/icons/icon_ego.png",
	"wealth":       "res://assets/images/icons/icon_wealth.png",
	"hate":         "res://assets/images/icons/icon_hate.png",
}

var _value_labels: Array = []
var _preview_labels: Array = []


func _ready() -> void:
	_build_ui()
	refresh()


func _build_ui() -> void:
	for i in range(4):
		var key := PARAM_KEYS[i]
		var col := VBoxContainer.new()
		col.position = Vector2(i * 180 + 10, 0)
		col.size = Vector2(160, 110)
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		add_child(col)

		var icon := TextureRect.new()
		var tex := load(ICON_PATHS[key])
		if tex:
			icon.texture = tex
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(48, 48)
		col.add_child(icon)

		var lbl := Label.new()
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 20)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		col.add_child(lbl)
		_value_labels.append(lbl)

		var preview := Label.new()
		preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		preview.add_theme_font_size_override("font_size", 16)
		preview.visible = false
		col.add_child(preview)
		_preview_labels.append(preview)


# パラメーター値を表示に反映する（スワイプ後・フェーズ進行時に呼ぶ）
func refresh() -> void:
	for i in range(4):
		var key := PARAM_KEYS[i]
		var val: int = GameState.params[key]
		_value_labels[i].text = str(val)
		_value_labels[i].add_theme_color_override("font_color", _get_danger_color(key, val))


# スワイプ中にstat_changesをプレビュー表示する
func show_preview(stat_changes: Dictionary) -> void:
	for i in range(4):
		var key := PARAM_KEYS[i]
		var change: int = stat_changes.get(key, 0)
		if change > 0:
			_preview_labels[i].text = "↑+" + str(change)
			_preview_labels[i].add_theme_color_override("font_color", Color(0.4, 1.0, 0.4))
			_preview_labels[i].visible = true
		elif change < 0:
			_preview_labels[i].text = "↓" + str(change)
			_preview_labels[i].add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
			_preview_labels[i].visible = true
		else:
			_preview_labels[i].visible = false


# プレビューを非表示にする
func clear_preview() -> void:
	for lbl in _preview_labels:
		lbl.visible = false


func _get_danger_color(key: String, val: int) -> Color:
	var danger: float
	match key:
		"independence", "wealth":
			danger = 1.0 - (val / 100.0)  # 値が低いほど危険
		_:
			danger = val / 100.0           # 値が高いほど危険
	return Color(1.0, 1.0 - danger * 0.8, 1.0 - danger * 0.8)
