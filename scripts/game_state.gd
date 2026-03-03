extends Node

# パラメーター（0〜100, 初期値50）
var params: Dictionary = {
	"independence": 50,
	"ego":          50,
	"wealth":       50,
	"hate":         50,
}

var current_phase: int = 0       # 0=幼児 〜 4=社会人
var card_index: int = 0          # フェーズ内カード番号（0〜4）
var pending_ending_id: String = ""  # エンディング画面に渡すID

const PHASES: Array[String] = ["幼児", "小学校", "中学校", "高校", "社会人"]
const PHASE_AGES: Array[int] = [3, 9, 13, 16, 23]

signal param_changed(key: String, new_val: int)
signal bad_end_triggered(ending_id: String)
signal phase_cleared(next_phase: int)


# stat_changes を適用してパラメーターを更新し、バッドエンド判定を行う
func apply_changes(stat_changes: Dictionary) -> void:
	for key in stat_changes:
		params[key] = clamp(params[key] + stat_changes[key], 0, 100)
		param_changed.emit(key, params[key])
	_check_bad_end()


func _check_bad_end() -> void:
	if params["independence"] <= 0:
		bad_end_triggered.emit("end_neet")
	elif params["ego"] >= 100:
		bad_end_triggered.emit("end_criminal")
	elif params["wealth"] <= 0:
		bad_end_triggered.emit("end_bankrupt")
	elif params["hate"] >= 100:
		bad_end_triggered.emit("end_cancelled")


# カードを1枚進める。フェーズ完了・ゲーム完走を検出してシグナルを発行する
func advance_card() -> void:
	card_index += 1
	if card_index >= 5:
		card_index = 0
		current_phase += 1
		if current_phase >= 5:
			# 社会人フェーズ完走 → 最悪パラメーターでエンディング分岐
			bad_end_triggered.emit(get_final_ending())
		else:
			phase_cleared.emit(current_phase)


# 社会人フェーズ完走時：限界値に最も近いパラメーターでエンディングを決定する
func get_final_ending() -> String:
	var worst: Dictionary = {
		"independence": 100 - params["independence"],
		"ego":          params["ego"],
		"wealth":       100 - params["wealth"],
		"hate":         params["hate"],
	}
	var top_key: String = "independence"
	for key in ["ego", "wealth", "hate"]:
		if worst[key] > worst[top_key]:
			top_key = key
	var ending_map: Dictionary = {
		"independence": "end_neet",
		"ego":          "end_criminal",
		"wealth":       "end_bankrupt",
		"hate":         "end_cancelled",
	}
	return ending_map[top_key]


# タイトルに戻る際にゲーム状態を完全リセットする
func reset() -> void:
	params = {"independence": 50, "ego": 50, "wealth": 50, "hate": 50}
	current_phase = 0
	card_index = 0
	pending_ending_id = ""
