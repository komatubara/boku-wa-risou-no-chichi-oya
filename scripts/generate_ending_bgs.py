#!/usr/bin/env python3
"""
エンディング背景画像を Gemini API で生成するスクリプト
Usage: python scripts/generate_ending_bgs.py
"""

import os
import sys
import time
from pathlib import Path

# .env ファイルを読み込む
env_path = Path(__file__).parent.parent / ".env"
if env_path.exists():
    for line in env_path.read_text(encoding="utf-8").splitlines():
        if "=" in line and not line.startswith("#"):
            k, v = line.split("=", 1)
            os.environ.setdefault(k.strip(), v.strip())

from google import genai
from google.genai import types

API_KEY = os.environ.get("GEMINI_API_KEY", "")
if not API_KEY:
    print("Error: GEMINI_API_KEY not found in .env or environment")
    sys.exit(1)

MODEL = "gemini-3.1-flash-image-preview"

client = genai.Client(api_key=API_KEY)

OUTPUT_DIR = Path(__file__).parent.parent / "assets/images/endings"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

STYLE = (
    "16-bit pixel art style, dramatic moody scene, "
    "rich atmospheric lighting, detailed environment, "
    "portrait composition, cinematic pixel art, "
    "dark melancholic tone, no characters visible, "
)

ENDINGS = {
    "end_doll": (
        STYLE
        + "dark empty room with a wooden chair in center, "
        + "tangled marionette strings hanging from ceiling above the chair, "
        + "dim spotlight from above, shadows stretching across bare floorboards, "
        + "eerie and hollow atmosphere"
    ),
    "end_independent": (
        STYLE
        + "night train station platform, single overhead lamp casting warm light, "
        + "train disappearing into dark tunnel in distance, "
        + "lone small suitcase left on empty platform, "
        + "melancholic farewell atmosphere"
    ),
    "end_broken": (
        STYLE
        + "sparse minimalist room, empty table and single chair in center, "
        + "bare gray walls, cold light from small high window, "
        + "extreme stillness and emptiness, suffocating silence"
    ),
    "end_neet": (
        STYLE
        + "dark cluttered bedroom, curtains completely shut, "
        + "food tray left at closed door, piles of garbage bags on floor, "
        + "faint blue glow from old computer monitor, years of isolation and decay"
    ),
    "end_criminal": (
        STYLE
        + "hospital private room at night, empty hospital bed with rumpled white sheets, "
        + "bare bedside table, window showing cold dark winter sky, "
        + "solitary and abandoned atmosphere"
    ),
    "end_bankrupt": (
        STYLE
        + "empty house interior, bare wooden floors, "
        + "faint rectangular outlines on walls where paintings once hung, "
        + "single bankruptcy notice envelope on floor, "
        + "desolate stripped-bare atmosphere"
    ),
    "end_cancelled": (
        STYLE
        + "pitch dark room lit only by glowing smartphone screen, "
        + "screen filled with flood of angry red notification icons and comments, "
        + "ominous digital red glow casting harsh shadows, "
        + "overwhelming social media firestorm atmosphere"
    ),
}


def generate_image(ending_id: str, prompt: str) -> bool:
    output_path = OUTPUT_DIR / f"{ending_id}.png"
    print(f"Generating {ending_id}...", end=" ", flush=True)

    try:
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
            ),
        )

        for part in response.candidates[0].content.parts:
            if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                image_data = part.inline_data.data
                if isinstance(image_data, str):
                    import base64
                    image_data = base64.b64decode(image_data)
                with open(output_path, "wb") as f:
                    f.write(image_data)
                print(f"OK saved ({len(image_data) // 1024}KB)")
                return True

        print("FAIL no image in response")
        return False

    except Exception as e:
        print(f"FAIL error: {e}")
        return False


def main():
    skip_existing = "--skip-existing" in sys.argv

    targets = {}
    for ending_id, prompt in ENDINGS.items():
        out = OUTPUT_DIR / f"{ending_id}.png"
        if skip_existing and out.exists() and out.stat().st_size > 10_000:
            print(f"SKIP {ending_id}.png skipped (exists)")
            continue
        targets[ending_id] = prompt

    print(f"\nGenerating {len(targets)} images -> {OUTPUT_DIR}\n")

    success = 0
    failed = []

    for i, (ending_id, prompt) in enumerate(targets.items(), 1):
        print(f"[{i}/{len(targets)}] ", end="")
        ok = generate_image(ending_id, prompt)
        if ok:
            success += 1
        else:
            failed.append(ending_id)
        if i < len(targets):
            time.sleep(4)  # 無料枠: 15 RPM

    print(f"\n{'=' * 40}")
    print(f"Done: {success}/{len(targets)} generated")
    if failed:
        print(f"Failed: {', '.join(failed)}")
    if success == len(targets):
        print("All images ready!")


if __name__ == "__main__":
    main()
