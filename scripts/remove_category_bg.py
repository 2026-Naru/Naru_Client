"""
Category image background remover
Removes near-white backgrounds from cat_*.png files and saves transparent PNGs.

Tune these values if results look off:
  WHITE_THRESHOLD  – pixels with R,G,B all above this are treated as background (0–255)
  EDGE_FEATHER     – how many edge pixels to soften (0 = hard edge, 2–4 = slight blur)
"""

from pathlib import Path
from PIL import Image
import numpy as np

# ── CONFIG ────────────────────────────────────────────────────────────────────
WHITE_THRESHOLD = 230   # raise to keep more of image, lower to cut more aggressively
EDGE_FEATHER    = 2     # softens jagged borders (pixels)
PADDING         = 8     # transparent margin kept around cropped content (pixels)
# ─────────────────────────────────────────────────────────────────────────────

SRC_DIR  = Path(__file__).parent.parent / "assets" / "images"
DEST_DIR = Path(__file__).parent.parent / "assets" / "images" / "category_transparent"
DEST_DIR.mkdir(parents=True, exist_ok=True)

def remove_white_bg(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    data = np.array(rgba, dtype=np.float32)

    r, g, b, a = data[..., 0], data[..., 1], data[..., 2], data[..., 3]

    # Pixels that look like white/near-white background
    is_bg = (r >= WHITE_THRESHOLD) & (g >= WHITE_THRESHOLD) & (b >= WHITE_THRESHOLD)

    # Build alpha: bg → 0, content → 255
    new_alpha = np.where(is_bg, 0.0, 255.0)

    if EDGE_FEATHER > 0:
        from PIL import ImageFilter
        alpha_img = Image.fromarray(new_alpha.astype(np.uint8))
        alpha_img = alpha_img.filter(ImageFilter.GaussianBlur(radius=EDGE_FEATHER))
        new_alpha = np.array(alpha_img, dtype=np.float32)

    data[..., 3] = new_alpha
    return Image.fromarray(data.astype(np.uint8))


def autocrop(img: Image.Image, padding: int = PADDING) -> Image.Image:
    bbox = img.getbbox()   # returns None if fully transparent
    if bbox is None:
        return img
    l, t, r, b = bbox
    w, h = img.size
    l = max(0, l - padding)
    t = max(0, t - padding)
    r = min(w, r + padding)
    b = min(h, b + padding)
    return img.crop((l, t, r, b))


def process_file(src: Path) -> tuple[bool, str]:
    try:
        img = Image.open(src)
        result = remove_white_bg(img)
        result = autocrop(result)

        # Warn if the output is almost fully transparent (likely a bad input)
        arr = np.array(result)
        opaque_ratio = (arr[..., 3] > 128).sum() / max(arr[..., 3].size, 1)
        warning = ""
        if opaque_ratio < 0.05:
            warning = f"  ⚠  only {opaque_ratio*100:.1f}% opaque — check WHITE_THRESHOLD"

        dest_name = src.stem + "_transparent.png"
        dest_path = DEST_DIR / dest_name
        result.save(dest_path, "PNG")
        return True, warning
    except Exception as e:
        return False, str(e)


def main():
    targets = sorted(SRC_DIR.glob("cat_*.png"))
    if not targets:
        print("No cat_*.png files found in", SRC_DIR)
        return

    ok, warn, fail = [], [], []
    for src in targets:
        success, msg = process_file(src)
        dest = DEST_DIR / (src.stem + "_transparent.png")
        if success:
            if msg:
                warn.append((src.name, msg))
                print(f"  [WARN] {src.name}{msg}")
            else:
                ok.append(src.name)
                print(f"  [OK]   {src.name}  →  {dest.name}")
        else:
            fail.append((src.name, msg))
            print(f"  [FAIL] {src.name}: {msg}")

    print()
    print(f"Done: {len(ok)} ok, {len(warn)} warnings, {len(fail)} failed")
    print(f"Output: {DEST_DIR}")

    if warn:
        print("\nImages that may need manual review (nearly fully transparent):")
        for name, msg in warn:
            print(f"  • {name}{msg}")

    if fail:
        print("\nFailed files:")
        for name, msg in fail:
            print(f"  • {name}: {msg}")


if __name__ == "__main__":
    main()
