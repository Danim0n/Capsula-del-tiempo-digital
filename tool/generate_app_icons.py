"""Genera los iconos de todas las plataformas desde el original de branding.

Requiere Pillow. Se ejecuta desde la raiz del proyecto con:
  python tool/generate_app_icons.py
"""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets" / "branding" / "app_icon_source.png"
IVORY = (250, 246, 237, 255)


def resized(image: Image.Image, size: int) -> Image.Image:
    return image.resize((size, size), Image.Resampling.LANCZOS)


def save_png(image: Image.Image, path: Path, size: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    resized(image, size).save(path, format="PNG", optimize=True)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.width != source.height:
        side = min(source.size)
        left = (source.width - side) // 2
        top = (source.height - side) // 2
        source = source.crop((left, top, left + side, top + side))

    flattened = Image.alpha_composite(
        Image.new("RGBA", source.size, IVORY), source
    ).convert("RGB")

    android_sizes = {
        "mdpi": 48,
        "hdpi": 72,
        "xhdpi": 96,
        "xxhdpi": 144,
        "xxxhdpi": 192,
    }
    adaptive_sizes = {
        "mdpi": 108,
        "hdpi": 162,
        "xhdpi": 216,
        "xxhdpi": 324,
        "xxxhdpi": 432,
    }
    for density, size in android_sizes.items():
        save_png(
            flattened,
            ROOT
            / "android"
            / "app"
            / "src"
            / "main"
            / "res"
            / f"mipmap-{density}"
            / "ic_launcher.png",
            size,
        )
    for density, size in adaptive_sizes.items():
        save_png(
            flattened,
            ROOT
            / "android"
            / "app"
            / "src"
            / "main"
            / "res"
            / f"drawable-{density}"
            / "ic_launcher_foreground.png",
            size,
        )

    ios_dir = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    for filename, size in ios_sizes.items():
        save_png(flattened, ios_dir / filename, size)

    macos_dir = (
        ROOT / "macos" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
    )
    for size in (16, 32, 64, 128, 256, 512, 1024):
        save_png(flattened, macos_dir / f"app_icon_{size}.png", size)

    web_dir = ROOT / "web"
    save_png(source, web_dir / "favicon.png", 32)
    save_png(source, web_dir / "icons" / "Icon-192.png", 192)
    save_png(source, web_dir / "icons" / "Icon-512.png", 512)
    save_png(flattened, web_dir / "icons" / "Icon-maskable-192.png", 192)
    save_png(flattened, web_dir / "icons" / "Icon-maskable-512.png", 512)

    windows_icon = ROOT / "windows" / "runner" / "resources" / "app_icon.ico"
    windows_icon.parent.mkdir(parents=True, exist_ok=True)
    resized(source, 256).save(
        windows_icon,
        format="ICO",
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )

    print("Iconos generados desde", SOURCE)


if __name__ == "__main__":
    main()
