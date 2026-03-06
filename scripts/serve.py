"""
ローカルデバッグ用HTTPサーバー
Godot Web ビルドに必要な COOP/COEP ヘッダーを付与して配信する

使い方:
  cd export
  python ../scripts/serve.py

ブラウザで http://localhost:8080 にアクセス
"""

import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler


class CORPHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        super().end_headers()

    def log_message(self, format, *args):
        print(f"[serve] {self.address_string()} - {format % args}")


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
    # export/ ディレクトリをルートとして配信
    export_dir = os.path.join(os.path.dirname(__file__), "..", "export")
    os.chdir(export_dir)
    server = HTTPServer(("localhost", port), CORPHandler)
    print(f"Serving {os.path.abspath('.')} at http://localhost:{port}")
    print("Ctrl+C で停止")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nサーバーを停止しました")
