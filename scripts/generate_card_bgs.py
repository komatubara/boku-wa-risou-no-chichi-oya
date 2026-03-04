#!/usr/bin/env python3
"""
カード背景画像を Gemini API で生成するスクリプト
Usage: python scripts/generate_card_bgs.py
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

OUTPUT_DIR = Path(__file__).parent.parent / "assets/images/ui/card_bgs"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

STYLE = (
    "16-bit pixel art style game scene background, "
    "solid opaque background, no transparency, "
    "wide horizontal composition, interior or exterior scene, "
    "detailed environment, warm pixel art colors, "
)

CARDS = {
    # 幼児フェーズ
    "inf_01": STYLE + "nursery daycare classroom interior, colorful wooden toy blocks on floor, small child-sized tables and chairs, animal drawings on pastel walls, warm cozy lighting",
    "inf_02": STYLE + "kindergarten outdoor playground, sunny day, slide and swing set, dirt path, cheerful blue sky with clouds",
    "inf_03": STYLE + "elementary school cafeteria interior, small tables with lunch trays, warm canteen atmosphere, fluorescent ceiling lights",
    "inf_04": STYLE + "school stage with red curtains, simple cardboard jungle props, single spotlight, wooden stage floor",
    "inf_05": STYLE + "school sandbox play area indoors, sandbox with small toys and shovels, large windows showing cloudy sky, cozy playroom",

    # 小学校フェーズ
    "elem_01": STYLE + "muddy school yard after rain, wet ground with puddles, school building facade in background, overcast gray sky",
    "elem_02": STYLE + "child bedroom morning scene, messy unmade bed with colorful blanket, alarm clock showing late time, warm sunlight through curtains",
    "elem_03": STYLE + "sports day track and field, colorful banner flags, school bleachers with crowd in background, bright sunny outdoor",
    "elem_04": STYLE + "child sick in bedroom, bed with white pillow, thermometer and cold compress visible, half-closed curtains, dim cozy atmosphere",
    "elem_05": STYLE + "elementary school classroom, rows of wooden desks, blackboard with chalk writing at front, afternoon sunlight through windows",

    # 中学校フェーズ
    "jh_01": STYLE + "close-up school desk with exam test paper showing many red marks, open textbook and pencil case, classroom background",
    "jh_02": STYLE + "teenager bedroom at night, glowing smartphone screen in dark room, desk with lamp, city lights through window",
    "jh_03": STYLE + "school gymnasium interior, wooden floor, high ceiling with lamps, sports equipment on sideline, empty court",
    "jh_04": STYLE + "school hallway with metal lockers along both walls, fluorescent overhead lighting, empty corridor stretching to distance",
    "jh_05": STYLE + "school cafeteria lunchtime, tray with unappetizing dark-colored food, tables and chairs in background, fluorescent lighting",

    # 高校フェーズ
    "hs_01": STYLE + "library study room, desk covered in stacked textbooks and mock exam papers showing poor grades, bookshelves in background",
    "hs_02": STYLE + "suburban street in winter, mailbox with official envelope, bare leafless trees, cold gray overcast sky",
    "hs_03": STYLE + "high school classroom front area, teacher wooden desk with small box for confiscated items, chalkboard background",
    "hs_04": STYLE + "dark gloomy teenager bedroom, curtains tightly shut, pile of tissues on floor, empty snack bags, very dim lighting",
    "hs_05": STYLE + "bright art classroom, wooden easel with canvas, paint brushes in jar, colorful palette, large windows with natural light",

    # 社会人フェーズ
    "ad_01": STYLE + "corporate office waiting room, rows of formal chairs, reception counter in background, professional sterile atmosphere",
    "ad_02": STYLE + "office interior with cubicles, angry boss figure at large desk, overwhelmed worker standing, fluorescent office lighting",
    "ad_03": STYLE + "office late at night, city lights through large windows, lone glowing computer on desk, dark atmospheric mood",
    "ad_04": STYLE + "office desk completely buried under towering stacks of papers and folders, chaotic overwhelmed atmosphere, office background",
    "ad_05": STYLE + "apartment building exterior, city street with moving boxes piled outside, bright hopeful urban scenery, clear sky",
}


def generate_image(card_id: str, prompt: str) -> bool:
    output_path = OUTPUT_DIR / f"{card_id}.png"
    print(f"Generating {card_id}...", end=" ", flush=True)

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
    # 生成済みをスキップするか確認
    skip_existing = "--skip-existing" in sys.argv

    targets = {}
    for card_id, prompt in CARDS.items():
        out = OUTPUT_DIR / f"{card_id}.png"
        if skip_existing and out.exists() and out.stat().st_size > 10_000:
            print(f"SKIP {card_id}.png skipped (exists)")
            continue
        targets[card_id] = prompt

    print(f"\nGenerating {len(targets)} images → {OUTPUT_DIR}\n")

    success = 0
    failed = []

    for i, (card_id, prompt) in enumerate(targets.items(), 1):
        print(f"[{i}/{len(targets)}] ", end="")
        ok = generate_image(card_id, prompt)
        if ok:
            success += 1
        else:
            failed.append(card_id)
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
