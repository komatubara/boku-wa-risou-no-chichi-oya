@tool
extends SceneTree

# GDScriptエラー検出スクリプト（headlessモード用）
# 使用法: godot --headless --script res://tools/check_errors.gd --path <project_dir>
#
# 注意: Autoload (GameState, CardManager) を参照するスクリプトは
#       headlessスクリプトモードでは「Identifier not found」になるが、
#       これはhealessモード特有の誤検知。実行時は正常に動作する。

# Autoloadに依存しないスクリプト（構文チェック可能）
const STANDALONE_SCRIPTS: Array[String] = [
	"res://scripts/game_state.gd",
	"res://scripts/card_manager.gd",
	"res://scripts/card_ui.gd",
	"res://scripts/how_to_play.gd",
]

# Autoloadに依存するスクリプト（実行時のみ検証可）
const RUNTIME_ONLY_SCRIPTS: Array[String] = [
	"res://scripts/param_icons.gd",
	"res://scripts/title.gd",
	"res://scripts/game.gd",
	"res://scripts/phase_transition.gd",
	"res://scripts/ending.gd",
]


func _init() -> void:
	var errors: int = 0
	print("=== GDScript 構文チェック ===")
	print("")
	print("--- スタンドアロン (完全チェック) ---")
	for path in STANDALONE_SCRIPTS:
		var script: GDScript = load(path)
		if script == null:
			print("  [ERROR] ", path)
			errors += 1
		else:
			print("  [OK]    ", path)

	print("")
	print("--- Autoload依存 (実行時のみ検証可) ---")
	for path in RUNTIME_ONLY_SCRIPTS:
		print("  [SKIP]  ", path, "  ← GameState/CardManager参照あり")

	print("")
	if errors > 0:
		print("エラー数: ", errors, " 件 (要修正)")
		quit(1)
	else:
		print("スタンドアロンスクリプト: 全て正常。")
		print("Autoload依存スクリプト:   Godotエディタで確認してください。")
		quit(0)
