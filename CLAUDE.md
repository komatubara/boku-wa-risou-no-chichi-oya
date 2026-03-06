# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

**ぼくはりそうのちちおや** — Reignsライク・カードスワイプ型ギャグシミュレーションゲーム。

息子のイベントに父親として2択で介入し、4つのパラメーターを管理しながらエンディングを目指す。「りそうのちちおや（モンペ）」として過干渉するほど息子がダメになっていく風刺コメディ。

- **開発エンジン:** Godot Engine 4.x
- **仕様書:** `ゲーム仕様書.md`

## カスタムコマンド（開発ワークフロー）

`.claude/commands/` に定義されたコマンドで開発を進める：

| コマンド | 用途 |
|---|---|
| `/project:design` | ゲーム全体設計のディスカッション |
| `/project:story` | ストーリー・キャラクター設定の深掘り |
| `/project:script` | イベントカードのテキスト・セリフ作成 |
| `/project:spec` | 仕様書の生成・更新 |
| `/project:code` | 仕様書に基づくコード実装 |
| `/project:asset` | PixelLab MCPでピクセルアート素材を生成 |
| `/project:audio` | ElevenLabs MCPでBGM・SEを生成 |
| `/project:balance` | カードのパラメーター変動をシミュレート・調整 |
| `/project:export` | Godotエクスポートから投稿サイトへのリリース手順ガイド |
| `/project:debug` | WebエクスポートしてPlaywrightでゲームを視覚的デバッグ |

**進め方の原則（全コマンド共通）：**
- 一度に聞く質問は最大3つ
- 各質問に選択肢を2〜4個提示
- 実装は1〜2機能単位で着実に進める
- 仕様書に書かれていない機能は勝手に追加しない

## ゲームアーキテクチャ

### コアループ
1. イベントカード表示（画面中央）
2. 左スワイプ（まともな対応）/ 右スワイプ（モンペ対応）を選択
3. スワイプ中、4つのパラメーターアイコンに影響度をプレビュー表示
4. 結果のギャグテキストとパラメーター増減をポップアップ表示
5. 一定枚数消化でフェーズ進行 → 最終的にエンディング

### パラメーター（0〜100、初期値50）

| パラメーター | キー | 0または100の結末 |
|---|---|---|
| 🧠 自立心 | `independence` | 0→究極のパラサイトニートエンド |
| 👑 ワガママ度 | `ego` | 100→暴力・犯罪者エンド |
| 💰 親の財力 | `wealth` | 0→自己破産エンド |
| 👁️ 世間のヘイト | `hate` | 100→警察介入・社会的抹殺エンド |

### フェーズ進行
幼児 → 小学校 → 中学校 → 高校 → 社会人（エンディング）

### イベントカードのJSONスキーマ

```json
{
  "card_id": "unique_id",
  "phase": "小学校",
  "character_image": "image_path.png",
  "event_text": "イベントの状況説明文",
  "swipe_left": {
    "action_text": "まともな選択肢の短いテキスト",
    "result_text": "選択後の結果・ギャグ描写",
    "stat_changes": { "independence": 10, "ego": -5, "wealth": 0, "hate": 0 }
  },
  "swipe_right": {
    "action_text": "モンペ選択肢の短いテキスト",
    "result_text": "過干渉によるギャグ描写と息子への悪影響",
    "stat_changes": { "independence": -15, "ego": 20, "wealth": -10, "hate": 30 }
  }
}
```

`stat_changes` の値は -100〜+100。

## MCP ツール

`.mcp.json` で以下が設定済み：

- **PixelLab** — キャラクター・UIのピクセルアート生成
- **ElevenLabs** — 音声生成（出力先: `assets/audio/`）
- **Context7** — ライブラリドキュメント参照
- **Serena** — ローカル開発サポート
