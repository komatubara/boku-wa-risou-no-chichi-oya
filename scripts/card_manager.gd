extends Node

const CARD_FILES: Dictionary = {
	0: "res://data/cards/infant.json",
	1: "res://data/cards/elementary.json",
	2: "res://data/cards/junior_high.json",
	3: "res://data/cards/high_school.json",
	4: "res://data/cards/adult.json",
}


# 指定フェーズのカード配列を返す
func load_cards(phase: int) -> Array:
	var path: String = CARD_FILES.get(phase, "")
	if path.is_empty():
		push_error("CardManager: Invalid phase index: %d" % phase)
		return []
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("CardManager: Cannot open file: " + path)
		return []
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("CardManager: JSON parse error in " + path)
		return []
	return json.data


# endings.json の全エンディングを配列で返す
func load_all_endings() -> Array:
	var file := FileAccess.open("res://data/endings.json", FileAccess.READ)
	if file == null:
		push_error("CardManager: Cannot open endings.json")
		return []
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("CardManager: JSON parse error in endings.json")
		return []
	return json.data


# ending_id に一致するエンディングデータを返す
func get_ending(ending_id: String) -> Dictionary:
	var file := FileAccess.open("res://data/endings.json", FileAccess.READ)
	if file == null:
		push_error("CardManager: Cannot open endings.json")
		return {}
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	file.close()
	if err != OK:
		push_error("CardManager: JSON parse error in endings.json")
		return {}
	for ending in json.data:
		if ending["ending_id"] == ending_id:
			return ending
	push_error("CardManager: ending_id not found: " + ending_id)
	return {}
