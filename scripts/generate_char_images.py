#!/usr/bin/env python3
"""
キャラクター画像を Gemini API で生成し、rembg で背景除去するスクリプト
Usage: python scripts/generate_char_images.py [--skip-existing]
"""

import os
import sys
import time
import base64
from io import BytesIO
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
from PIL import Image
from rembg import remove

API_KEY = os.environ.get("GEMINI_API_KEY", "")
if not API_KEY:
    print("Error: GEMINI_API_KEY not found in .env or environment")
    sys.exit(1)

MODEL = "gemini-3.1-flash-image-preview"

client = genai.Client(api_key=API_KEY)

BASE_DIR = Path(__file__).parent.parent / "assets/images"

STYLE = (
    "anime-style 2D character illustration, plain white background, "
    "upper body portrait, expressive face, simple clean art style, "
    "manga-inspired, no background scenery, "
)

# card_id -> (出力先相対パス, プロンプトサフィックス)
CHARACTERS = {
    "inf_01":   ("cards/infant/inf_01.png",           "toddler boy age 3-4, red teary eyes from crying, sad pouty expression"),
    "inf_02":   ("cards/infant/inf_02.png",           "toddler boy age 3-4, bandage on knee, proud brave expression pointing at knee"),
    "inf_03":   ("cards/infant/inf_03.png",           "toddler boy age 3-4, extremely disgusted face refusing food, mouth tightly shut"),
    "inf_04":   ("cards/infant/inf_04.png",           "toddler boy age 3-4, wearing monkey ear headband, embarrassed blushing"),
    "inf_05":   ("cards/infant/inf_05.png",           "toddler boy age 3-4, crying loudly with big tears, tantrum arms flailing"),
    "elem_01":  ("cards/elementary/elem_01.png",      "elementary school boy age 9, muddy school uniform, energetic wide grin"),
    "elem_02":  ("cards/elementary/elem_02.png",      "elementary school boy age 9, disheveled hair, panicked rushing expression"),
    "elem_03":  ("cards/elementary/elem_03.png",      "elementary school boy age 9, tearful expression showing scraped knee"),
    "elem_04":  ("cards/elementary/elem_04.png",      "elementary school boy age 9, sick pale face, sweating, holding thermometer"),
    "elem_05":  ("cards/elementary/elem_05.png",      "elementary school boy age 9, ashamed downcast head bowed, guilty expression"),
    "jh_01":    ("cards/junior_high/jh_01.png",       "junior high boy age 13, hiding papers behind back, nervous guilty look"),
    "jh_02":    ("cards/junior_high/jh_02.png",       "junior high boy age 13, staring at smartphone, lonely sad expression"),
    "jh_03":    ("cards/junior_high/jh_03.png",       "junior high boy age 13, sports uniform, slumped dejected disappointed expression"),
    "jh_04":    ("cards/junior_high/jh_04.png",       "junior high boy age 13, standing alone isolated, downcast lonely expression"),
    "jh_05":    ("cards/junior_high/jh_05.png",       "junior high boy age 13, extremely disgusted grimacing face"),
    "hs_01":    ("cards/high_school/hs_01.png",       "high school boy age 17, holding test paper, shocked pale horrified expression"),
    "hs_02":    ("cards/high_school/hs_02.png",       "high school boy age 17, staring at phone, extremely tense anxious expression"),
    "hs_03":    ("cards/high_school/hs_03.png",       "high school boy age 17, arms crossed sulking, rebellious defiant expression"),
    "hs_04":    ("cards/high_school/hs_04.png",       "high school boy age 17, blank hollow depressed expression, slouching"),
    "hs_05":    ("cards/high_school/hs_05.png",       "high school boy age 17, holding art sketchbook, earnest hopeful pleading expression"),
    "ad_01":    ("cards/adult/ad_01.png",              "young adult man age 23, business suit, slumped defeated expression"),
    "ad_02":    ("cards/adult/ad_02.png",              "young adult man age 23, casual clothes, quiet withdrawn reserved expression"),
    "ad_03":    ("cards/adult/ad_03.png",              "young adult man age 23, holding smartphone, distant vacant hollow expression"),
    "ad_04":    ("cards/adult/ad_04.png",              "young adult man age 23, overwhelmed by stack of papers, stressed panicked expression"),
    "ad_05":    ("cards/adult/ad_05.png",              "young adult man age 23, holding moving box, nervous hopeful expression"),
    "father":   ("characters/father.png",              "middle-aged man age 47, arms crossed, smug self-satisfied smirk, loosened necktie, slightly overweight, intimidating overbearing father"),
}

TARGET_H = 400


def generate_image(char_id: str, rel_path: str, prompt_suffix: str) -> bool:
    output_path = BASE_DIR / rel_path
    output_path.parent.mkdir(parents=True, exist_ok=True)
    print(f"Generating {char_id}...", end=" ", flush=True)

    prompt = STYLE + prompt_suffix

    try:
        response = client.models.generate_content(
            model=MODEL,
            contents=prompt,
            config=types.GenerateContentConfig(
                response_modalities=["IMAGE", "TEXT"],
            ),
        )

        image_data = None
        for part in response.candidates[0].content.parts:
            if part.inline_data and part.inline_data.mime_type.startswith("image/"):
                image_data = part.inline_data.data
                if isinstance(image_data, str):
                    image_data = base64.b64decode(image_data)
                break

        if image_data is None:
            print("FAIL no image in response")
            return False

        # rembg で背景除去 → 透過PNG
        removed = remove(image_data)
        img = Image.open(BytesIO(removed)).convert("RGBA")

        # 縦 TARGET_H px 基準にアスペクト比維持でリサイズ
        w, h = img.size
        new_w = int(w * TARGET_H / h)
        img = img.resize((new_w, TARGET_H), Image.LANCZOS)

        img.save(output_path, "PNG")
        print(f"OK saved ({output_path.stat().st_size // 1024}KB, {new_w}x{TARGET_H})")
        return True

    except Exception as e:
        print(f"FAIL error: {e}")
        return False


def main():
    skip_existing = "--skip-existing" in sys.argv

    targets = {}
    for char_id, (rel_path, prompt_suffix) in CHARACTERS.items():
        out = BASE_DIR / rel_path
        if skip_existing and out.exists() and out.stat().st_size > 10_000:
            print(f"SKIP {char_id} skipped (exists)")
            continue
        targets[char_id] = (rel_path, prompt_suffix)

    print(f"\nGenerating {len(targets)} character images → {BASE_DIR}\n")

    success = 0
    failed = []

    for i, (char_id, (rel_path, prompt_suffix)) in enumerate(targets.items(), 1):
        print(f"[{i}/{len(targets)}] ", end="")
        ok = generate_image(char_id, rel_path, prompt_suffix)
        if ok:
            success += 1
        else:
            failed.append(char_id)
        if i < len(targets):
            time.sleep(4)  # 無料枠: 15 RPM

    print(f"\n{'=' * 40}")
    print(f"Done: {success}/{len(targets)} generated")
    if failed:
        print(f"Failed: {', '.join(failed)}")
    if success == len(targets):
        print("All character images ready!")


if __name__ == "__main__":
    main()
