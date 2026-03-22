from __future__ import annotations

import base64
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
STATES = ["idle", "roll", "next_turn", "pause", "victory"]


def main() -> None:
    for state in STATES:
        encoded_path = BASE_DIR / f"big_walker_{state}.png.base64"
        png_path = BASE_DIR / f"big_walker_{state}.png"

        if not encoded_path.exists():
            raise FileNotFoundError(f"Missing encoded baseline: {encoded_path}")

        raw = base64.b64decode(encoded_path.read_text().strip())
        png_path.write_bytes(raw)
        print(f"Materialized {png_path.name} ({len(raw)} bytes)")


if __name__ == "__main__":
    main()
