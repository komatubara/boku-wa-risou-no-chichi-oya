---
description: ゲームをWebエクスポート→ローカルサーバーでPlaywrightによる視覚的デバッグを行う
---

# ビジュアルデバッグコマンド

あなたはQAエンジニアです。Godot CLIでWebエクスポートし、Playwrightでブラウザを操作してゲームを実際にプレイしながら視覚的なバグを洗い出します。

## 前提条件

- ローカルサーバーが起動済みであること（`python scripts/serve.py`）
- Playwright MCP が有効であること（`.mcp.json` 設定済み）

## 進め方のルール

- スクリーンショットは必ず `debug/` フォルダに保存する（例: `debug/filename.png`）
- バグは重要度（高・中・低）に分類して報告する
- ユーザーが `$ARGUMENTS` でデバッグ内容を指定した場合はそこに集中する（例: `タイトル画面` `エンディング` `フルプレイ`）

## 手順

### Step 1: Webエクスポート

Godot CLI でヘッドレスエクスポートを実行する：

```bash
cd "C:\Users\komic\workdir\ぼくはりそうのちちおや"
"C:\Users\komic\workdir\Godot_v4.6.1-stable_win64.exe\Godot_v4.6.1-stable_win64_console.exe" --headless --export-release "Web" export/index.html
```

エクスポート完了を確認する（`export/index.html` のタイムスタンプが更新されていること）。

### Step 2: ブラウザでゲームを起動

Playwright で `http://localhost:8080` にアクセスし、ゲームのロードを待つ（約6秒）。

### Step 3: 各画面のスクリーンショット取得・確認

以下の順番で画面を進めながら確認する：

1. **タイトル画面** — ロゴ・背景・ボタンの表示確認
2. **あそびかた画面** — テキスト表示・スクロール動作確認
3. **ゲーム開始** — パラメーター初期値（50/50/50/50）確認
4. **カードスワイプ** — スワイプ操作・プレビュー表示・パラメーター更新確認
5. **フェーズ移行画面** — 表示・タップ受付タイミング確認
6. **エンディング画面** — テキスト・キャラクター・「もう一度」ボタン確認

スワイプ操作は以下のJavaScriptで実行する：
```js
const canvas = document.querySelector('canvas');
const swipe = (dir) => {
  const x = 197, y = 265, dx = dir === 'right' ? 250 : -250;
  canvas.dispatchEvent(new MouseEvent('mousedown', {clientX: x, clientY: y, bubbles: true}));
  canvas.dispatchEvent(new MouseEvent('mousemove', {clientX: x + dx/2, clientY: y, bubbles: true}));
  canvas.dispatchEvent(new MouseEvent('mousemove', {clientX: x + dx, clientY: y, bubbles: true}));
  canvas.dispatchEvent(new MouseEvent('mouseup',   {clientX: x + dx, clientY: y, bubbles: true}));
};
```

### Step 4: フルプレイスルー（`$ARGUMENTS` が「フルプレイ」または未指定の場合）

全5フェーズ（幼児〜社会人、計25枚）をスワイプしてエンディングに到達する。
右スワイプ（モンペ）を基本としつつ、パラメーターが限界値（0/100）に近づいたら左スワイプに切り替える。

### Step 5: バグレポート出力

発見したバグを以下のフォーマットで報告する：

| # | 画面 | 内容 | 重要度 |
|---|---|---|---|
| 1 | 〇〇画面 | バグの内容 | 高/中/低 |

正常動作した項目も ✅ として列挙する。

### Step 6: 修正提案

重要度「高」のバグから順に修正方法を提案し、ユーザーの確認を取ってから実装に進む。
