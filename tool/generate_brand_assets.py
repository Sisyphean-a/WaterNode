from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parent.parent
ANDROID_ICON_SIZES = {
    48: ROOT / "android/app/src/main/res/mipmap-mdpi/ic_launcher.png",
    72: ROOT / "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
    96: ROOT / "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png",
    144: ROOT / "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png",
    192: ROOT / "android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png",
}
PNG_OUTPUT = ROOT / "assets/branding/waternode_icon.png"
ICO_OUTPUT = ROOT / "windows/runner/resources/app_icon.ico"
MASTER_SIZE = 1024


def _draw_drop(draw: ImageDraw.ImageDraw, scale: float) -> None:
    path = [
        (512 * scale, 248 * scale),
        (463 * scale, 321 * scale),
        (354 * scale, 432 * scale),
        (354 * scale, 570 * scale),
        (354 * scale, 671 * scale),
        (435 * scale, 752 * scale),
        (536 * scale, 752 * scale),
        (637 * scale, 752 * scale),
        (718 * scale, 671 * scale),
        (718 * scale, 570 * scale),
        (718 * scale, 438 * scale),
        (612 * scale, 323 * scale),
        (565 * scale, 256 * scale),
    ]
    draw.polygon(path, fill="#2DD4BF")


def _draw_node(draw: ImageDraw.ImageDraw, center: tuple[float, float], radius: float) -> None:
    x, y = center
    draw.ellipse((x - radius, y - radius, x + radius, y + radius), fill="#CFFAFE")
    inner = radius * 0.48
    draw.ellipse((x - inner, y - inner, x + inner, y + inner), fill="#0E7490")


def build_master_icon() -> Image.Image:
    image = Image.new("RGBA", (MASTER_SIZE, MASTER_SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    shadow = Image.new("RGBA", (MASTER_SIZE, MASTER_SIZE), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle((84, 94, 940, 950), radius=230, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(28))
    image.alpha_composite(shadow)

    draw.rounded_rectangle((64, 64, 960, 960), radius=240, fill="#0B1F2A")
    draw.rounded_rectangle((112, 112, 912, 912), radius=208, fill="#123649")
    draw.rounded_rectangle((156, 156, 868, 868), radius=184, outline="#164E63", width=10)

    scale = MASTER_SIZE / 1024
    _draw_drop(draw, scale)

    nodes = {
        (430 * scale, 408 * scale): 46 * scale,
        (630 * scale, 430 * scale): 40 * scale,
        (590 * scale, 622 * scale): 36 * scale,
    }
    for (start_x, start_y), (end_x, end_y) in (
        ((430 * scale, 408 * scale), (630 * scale, 430 * scale)),
        ((630 * scale, 430 * scale), (590 * scale, 622 * scale)),
        ((430 * scale, 408 * scale), (590 * scale, 622 * scale)),
    ):
        draw.line((start_x, start_y, end_x, end_y), fill="#7DD3FC", width=int(30 * scale))

    for center, radius in nodes.items():
        _draw_node(draw, center, radius)

    gloss = Image.new("RGBA", (MASTER_SIZE, MASTER_SIZE), (0, 0, 0, 0))
    gloss_draw = ImageDraw.Draw(gloss)
    gloss_draw.ellipse((212, 128, 676, 488), fill=(255, 255, 255, 36))
    gloss = gloss.filter(ImageFilter.GaussianBlur(18))
    image.alpha_composite(gloss)
    return image


def save_icon_outputs(image: Image.Image) -> None:
    PNG_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(PNG_OUTPUT)

    ICO_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    image.save(
        ICO_OUTPUT,
        format="ICO",
        sizes=[(16, 16), (24, 24), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )

    for size, path in ANDROID_ICON_SIZES.items():
        path.parent.mkdir(parents=True, exist_ok=True)
        resized = image.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(path)


def main() -> None:
    image = build_master_icon()
    save_icon_outputs(image)
    print("Generated branding assets:")
    print(f"- {PNG_OUTPUT.relative_to(ROOT)}")
    print(f"- {ICO_OUTPUT.relative_to(ROOT)}")
    for size, path in ANDROID_ICON_SIZES.items():
        print(f"- {path.relative_to(ROOT)} ({size}x{size})")


if __name__ == "__main__":
    main()
