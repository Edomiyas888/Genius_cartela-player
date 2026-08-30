#!/usr/bin/env python3
"""Compose the Besufikad Bingo lockup around the Waliya ibex artwork.

The photograph in assets/images/waliya_pair.png is the fixed part of the mark.
Everything else - the rainbow halo, the bingo balls and the BINGO wordmark -
is drawn here with Pillow, so the lockup can be retuned without redrawing the
animals:

    python3 tool/compose_logo.py

Two square lockups come out of it:

* ``logo.png``     - the full mark, wordmark included. Used in the card picker,
                     where it renders large enough to read.
* ``app_icon.png`` - medallion and rainbow only, for the 40 px app-bar mark
                     where balls and lettering would turn to mush.

Everything is drawn at 4x and downsampled, which is cheaper than hand-rolling
antialiasing for the arcs. The wordmark needs a heavy grotesque; the committed
PNGs mean a machine without that font can still build the app.
"""

import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "assets", "images")
ARTWORK = os.path.join(IMAGES, "waliya_pair.png")

SIZE = 1024
SS = 4  # supersampling factor

INK_DARK = (11, 13, 38)
INK_LIGHT = (36, 23, 72)
GOLD = (246, 197, 95)
GOLD_LIGHT = (255, 240, 196)

RAINBOW = [
    (255, 59, 48),    # red
    (255, 149, 0),    # orange
    (255, 204, 0),    # yellow
    (52, 199, 89),    # green
    (10, 132, 255),   # blue
    (65, 69, 214),    # indigo
    (175, 82, 222),   # violet
]

WORDMARK_FONTS = (
    "/System/Library/Fonts/Supplemental/Arial Black.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
    "/Library/Fonts/Arial Black.ttf",
)

# Layout, in final (1024 px) coordinates. The icon has no wordmark or balls to
# make room for, so its medallion grows and the group re-centres in the square.
HALO_BAND = 15
FULL = {"centre": (512, 420), "medallion": 270, "halo": 384}
ICON = {"centre": (512, 572), "medallion": 300, "halo": 420}
BALL_Y = 742
BALLS = [(300, 64, RAINBOW[0], "7"), (724, 64, RAINBOW[4], "21")]
CENTRE_BALL = (512, 70, RAINBOW[2], "42")
WORDMARK_BOX = (168, 836, 856, 956)


def font(paths, size):
    for path in paths:
        if os.path.exists(path):
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def badge(draw, size):
    """The rounded ink field the whole mark sits on."""
    for y in range(size):
        t = y / (size - 1)
        draw.line(
            [(0, y), (size, y)],
            fill=tuple(
                round(a + (b - a) * t) for a, b in zip(INK_DARK, INK_LIGHT)
            ),
        )


def rounded_mask(size, radius):
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size - 1, size - 1], radius, fill=255)
    return mask


def halo(draw, s, geometry):
    """The rainbow arcing over the medallion."""
    cx, cy = geometry["centre"]
    for index, colour in enumerate(RAINBOW):
        mid = geometry["halo"] - index * HALO_BAND - HALO_BAND / 2
        box = [(cx - mid) * s, (cy - mid) * s, (cx + mid) * s, (cy + mid) * s]
        draw.arc(box, 180, 360, fill=colour, width=round(HALO_BAND * s))


def medallion(canvas, s, geometry):
    """The artwork, circle-cropped and ringed in gold."""
    cx, cy = geometry["centre"]
    outer_r = geometry["medallion"]
    diameter = round(outer_r * 2 * s)
    art = Image.open(ARTWORK).convert("RGBA")
    # Cover the circle rather than fit it, so no ink shows through the crop.
    scale = diameter / min(art.size)
    art = art.resize(
        (round(art.width * scale), round(art.height * scale)), Image.LANCZOS
    )
    art = art.crop(
        (
            (art.width - diameter) // 2,
            max(0, (art.height - diameter) // 2 - round(12 * s)),
            (art.width - diameter) // 2 + diameter,
            max(0, (art.height - diameter) // 2 - round(12 * s)) + diameter,
        )
    )

    mask = Image.new("L", (diameter, diameter), 0)
    ImageDraw.Draw(mask).ellipse([0, 0, diameter - 1, diameter - 1], fill=255)
    canvas.paste(art, (round((cx - outer_r) * s), round((cy - outer_r) * s)), mask)

    draw = ImageDraw.Draw(canvas)
    for inset, colour, width in ((0, GOLD, 9), (10, GOLD_LIGHT, 3)):
        r = outer_r - inset
        draw.ellipse(
            [(cx - r) * s, (cy - r) * s, (cx + r) * s, (cy + r) * s],
            outline=colour,
            width=round(width * s),
        )


def ball(canvas, s, cx, cy, radius, colour, label):
    """A numbered bingo ball: coloured shell, white face, specular highlight."""
    draw = ImageDraw.Draw(canvas)
    draw.ellipse(
        [(cx - radius) * s, (cy - radius) * s, (cx + radius) * s, (cy + radius) * s],
        fill=colour,
    )
    face = radius * 0.66
    draw.ellipse(
        [(cx - face) * s, (cy - face) * s, (cx + face) * s, (cy + face) * s],
        fill=(255, 255, 255),
    )
    digits = font(WORDMARK_FONTS, round(radius * (1.05 if len(label) == 1 else 0.78) * s))
    draw.text((cx * s, cy * s), label, font=digits, fill=(18, 20, 46), anchor="mm")
    # Drawn on its own layer: ImageDraw replaces pixels rather than blending, so
    # a translucent fill straight onto the canvas would punch a hole instead.
    gloss = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(gloss).ellipse(
        [
            (cx - radius * 0.62) * s,
            (cy - radius * 0.74) * s,
            (cx - radius * 0.22) * s,
            (cy - radius * 0.48) * s,
        ],
        fill=(255, 255, 255, 140),
    )
    canvas.alpha_composite(gloss)


def wordmark(canvas, s):
    """BINGO, set in rainbow across an ink pill."""
    x0, y0, x1, y1 = WORDMARK_BOX
    draw = ImageDraw.Draw(canvas)
    draw.rounded_rectangle(
        [x0 * s, y0 * s, x1 * s, y1 * s],
        radius=round((y1 - y0) / 2 * s),
        fill=INK_DARK + (235,),
        outline=GOLD,
        width=round(3 * s),
    )

    letters = "BINGO"
    face = font(WORDMARK_FONTS, round(78 * s))
    tracking = round(14 * s)
    widths = [draw.textlength(ch, font=face) for ch in letters]
    total = sum(widths) + tracking * (len(letters) - 1)

    # Set the letters into a mask, then pour a rainbow gradient through it.
    mask = Image.new("L", canvas.size, 0)
    mask_draw = ImageDraw.Draw(mask)
    x = (x0 + x1) / 2 * s - total / 2
    for ch, width in zip(letters, widths):
        mask_draw.text((x, (y0 + y1) / 2 * s), ch, font=face, fill=255, anchor="lm")
        x += width + tracking

    gradient = Image.new("RGB", canvas.size)
    stops = RAINBOW[:5]
    span = total
    left = (x0 + x1) / 2 * s - total / 2
    grad_draw = ImageDraw.Draw(gradient)
    for px in range(canvas.size[0]):
        t = min(max((px - left) / span, 0.0), 1.0) * (len(stops) - 1)
        lo = min(int(t), len(stops) - 2)
        f = t - lo
        grad_draw.line(
            [(px, 0), (px, canvas.size[1])],
            fill=tuple(
                round(a + (b - a) * f) for a, b in zip(stops[lo], stops[lo + 1])
            ),
        )
    canvas.paste(gradient, (0, 0), mask)


def build(with_wordmark):
    s = SS
    size = SIZE * s
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    field = Image.new("RGB", (size, size))
    badge(ImageDraw.Draw(field), size)
    canvas.paste(field, (0, 0), rounded_mask(size, round(140 * s)))

    geometry = FULL if with_wordmark else ICON
    halo(ImageDraw.Draw(canvas), s, geometry)
    medallion(canvas, s, geometry)

    if with_wordmark:
        for cx, radius, colour, label in BALLS:
            ball(canvas, s, cx, BALL_Y, radius, colour, label)
        cx, radius, colour, label = CENTRE_BALL
        ball(canvas, s, cx, BALL_Y + 18, radius, colour, label)
        wordmark(canvas, s)

    return canvas.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    build(with_wordmark=True).save(os.path.join(IMAGES, "logo.png"))
    build(with_wordmark=False).save(os.path.join(IMAGES, "app_icon.png"))
    print("Composed logo.png and app_icon.png.")


if __name__ == "__main__":
    main()
