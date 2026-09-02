"""Importa y optimiza imágenes verticales para usarlas como portadas.

Requiere Pillow. Ejemplo:
  python tool/import_cover_images.py --start 13 imagen1.png imagen2.png
"""

import argparse
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = ROOT / "assets" / "images" / "covers"
OUTPUT_SIZE = (768, 1152)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("sources", nargs="+", type=Path)
    parser.add_argument("--start", type=int, default=1)
    args = parser.parse_args()

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    for offset, source_path in enumerate(args.sources):
        number = args.start + offset
        destination = OUTPUT_DIR / f"cover_{number:02d}.webp"
        with Image.open(source_path) as source:
            cover = ImageOps.fit(
                source.convert("RGB"),
                OUTPUT_SIZE,
                method=Image.Resampling.LANCZOS,
                centering=(0.5, 0.5),
            )
            cover.save(destination, "WEBP", quality=88, method=6)
        print(destination.relative_to(ROOT))


if __name__ == "__main__":
    main()
