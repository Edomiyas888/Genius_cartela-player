#!/usr/bin/env python3
"""Generate the Besufikad Bingo launcher icons.

NOTE: the in-app logo (assets/images/logo.png) and app-bar mark
(assets/images/app_icon.png) are no longer drawn here - they are cut from the
Waliya ibex artwork in assets/images/waliya_pair.png. Re-running this script
will overwrite them with the drawn mark below, so restore those two files from
git afterwards if you only meant to refresh the launcher icons.

The artwork is a Waliya (walia ibex) in front of a rainbow, with a cartela and
bingo balls at its feet. It is drawn as an SVG and rasterised into the in-app
asset, the Android mipmaps, the iOS AppIcon set and the web icons, so a tweak
here re-brands the whole app in one run:

    pip install cairosvg pillow fonttools
    python3 tool/generate_logo.py

Two square lockups come out of the same drawing:

* ``logo.png``     - the full mark, including the BINGO lettering. Used in the
                     app, where it is rendered large enough to read.
* ``app_icon.png`` - the same scene without the lettering and with the animal
                     enlarged, so it still reads at a 48 px launcher size.

Text is converted to outlines at build time, so the committed SVG renders
identically without the generating machine's fonts.
"""

import math
import os

import cairosvg
from PIL import Image
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.ttLib import TTFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

SIZE = 512

# ---------------------------------------------------------------- palette ---
INK_DARK = "#0B0D26"
INK_LIGHT = "#241748"

RAINBOW = [
    "#FF3B30",  # red
    "#FF9500",  # orange
    "#FFCC00",  # yellow
    "#34C759",  # green
    "#0A84FF",  # blue
    "#4145D6",  # indigo
    "#AF52DE",  # violet
]

# Walia ibex colouring: a chestnut-brown coat, pale muzzle and eye rings, a
# dark blaze down the nose and a black beard.
COAT_DARK = "#3E2A19"
COAT_MID = "#7A5432"
COAT_LIGHT = "#A87F4C"
BLAZE = "#3A2517"
MUZZLE = "#D9C6A8"
EYE_RING = "#C9AE86"
BEARD = "#1E1409"
HORN_DARK = "#6E4A1C"
HORN_MID = "#C09452"
HORN_LIGHT = "#F2E0AE"

FONT_CANDIDATES = [
    "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
    "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
]


# ------------------------------------------------------------- typography ---


def _load_font():
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            return TTFont(path)
    raise SystemExit(
        "No bold sans font found. Install fonts-dejavu-core, or add a path to "
        "FONT_CANDIDATES."
    )


_FONT = _load_font()
_GLYPHS = _FONT.getGlyphSet()
_CMAP = _FONT.getBestCmap()
_UPEM = _FONT["head"].unitsPerEm


def text_path(text, size, x, y, anchor="middle", letter_spacing=0.0):
    """Return an SVG path `d` for `text` laid out with its baseline at `y`.

    Converting to outlines keeps the committed SVG independent of any font
    being installed on the machine that renders it.
    """
    scale = size / _UPEM
    advances = []
    for char in text:
        name = _CMAP.get(ord(char))
        if name is None:
            raise SystemExit(f"Font has no glyph for {char!r}")
        advances.append((name, _FONT["hmtx"][name][0] * scale + letter_spacing))

    total = sum(advance for _, advance in advances)
    if anchor == "middle":
        pen_x = x - total / 2
    elif anchor == "end":
        pen_x = x - total
    else:
        pen_x = x

    parts = []
    for name, advance in advances:
        pen = SVGPathPen(_GLYPHS)
        _GLYPHS[name].draw(pen)
        d = pen.getCommands()
        if d:
            # Glyph space is y-up; flip it and drop it at the pen position.
            parts.append(
                f'<g transform="translate({pen_x:.2f},{y:.2f}) '
                f'scale({scale:.5f},{-scale:.5f})"><path d="{d}"/></g>'
            )
        pen_x += advance
    return "\n        ".join(parts)


# ------------------------------------------------------------ bezier math ---


def _bezier(p0, p1, p2, p3, t):
    u = 1 - t
    return (
        u ** 3 * p0[0] + 3 * u * u * t * p1[0] + 3 * u * t * t * p2[0] + t ** 3 * p3[0],
        u ** 3 * p0[1] + 3 * u * u * t * p1[1] + 3 * u * t * t * p2[1] + t ** 3 * p3[1],
    )


def _bezier_tangent(p0, p1, p2, p3, t):
    u = 1 - t
    x = 3 * u * u * (p1[0] - p0[0]) + 6 * u * t * (p2[0] - p1[0]) + 3 * t * t * (p3[0] - p2[0])
    y = 3 * u * u * (p1[1] - p0[1]) + 6 * u * t * (p2[1] - p1[1]) + 3 * t * t * (p3[1] - p2[1])
    length = math.hypot(x, y) or 1.0
    return x / length, y / length


# A walia ibex horn: thick at the skull, sweeping up and back in a long arc,
# tapering to a blunt tip.
HORN = ((240, 252), (232, 150), (176, 78), (94, 116))
HORN_BASE_HALF_WIDTH = 31.0
HORN_TIP_HALF_WIDTH = 6.5
HORN_STEPS = 72
RIDGE_COUNT = 13


def _horn_half_width(t):
    return HORN_TIP_HALF_WIDTH + (HORN_BASE_HALF_WIDTH - HORN_TIP_HALF_WIDTH) * (1 - t) ** 1.3


def horn_outline():
    left, right = [], []
    for step in range(HORN_STEPS + 1):
        t = step / HORN_STEPS
        px, py = _bezier(*HORN, t)
        tx, ty = _bezier_tangent(*HORN, t)
        half = _horn_half_width(t)
        left.append((px - ty * half, py + tx * half))
        right.append((px + ty * half, py - tx * half))
    points = left + list(reversed(right))
    body = " ".join(f"L{x:.1f},{y:.1f}" for x, y in points[1:])
    return f"M{points[0][0]:.1f},{points[0][1]:.1f} {body} Z"


def horn_shadow():
    """The underside of the horn, for a bit of roundness."""
    points = []
    for step in range(HORN_STEPS + 1):
        t = step / HORN_STEPS
        px, py = _bezier(*HORN, t)
        tx, ty = _bezier_tangent(*HORN, t)
        half = _horn_half_width(t)
        points.append((px - ty * half, py + tx * half))
    for step in range(HORN_STEPS, -1, -1):
        t = step / HORN_STEPS
        px, py = _bezier(*HORN, t)
        tx, ty = _bezier_tangent(*HORN, t)
        half = _horn_half_width(t) * 0.32
        points.append((px - ty * half, py + tx * half))
    body = " ".join(f"L{x:.1f},{y:.1f}" for x, y in points[1:])
    return f"M{points[0][0]:.1f},{points[0][1]:.1f} {body} Z"


def horn_ridges():
    """Transverse growth knobs, drawn as tapered arcs across the horn face."""
    ridges = []
    for step in range(1, RIDGE_COUNT + 1):
        t = step / (RIDGE_COUNT + 2.2)
        px, py = _bezier(*HORN, t)
        tx, ty = _bezier_tangent(*HORN, t)
        half = _horn_half_width(t) * 0.92
        x1, y1 = px - ty * half, py + tx * half
        x2, y2 = px + ty * half, py - tx * half
        # Bow each ridge slightly along the horn so it reads as a raised knob.
        bow = _horn_half_width(t) * 0.42
        cx, cy = px + tx * bow, py + ty * bow
        width = 2.0 + 4.0 * (1 - t)
        ridges.append(
            f'<path d="M{x1:.1f},{y1:.1f} Q{cx:.1f},{cy:.1f} {x2:.1f},{y2:.1f}" '
            f'stroke-width="{width:.1f}"/>'
        )
    return "\n          ".join(ridges)


# ------------------------------------------------------------- ibex shapes ---

# Skull, narrowing to the muzzle. Drawn a touch asymmetric-free (front view).
HEAD = (
    "M256,236 "
    "C288,236 312,247 318,268 "
    "C325,293 318,322 306,350 "
    "C297,375 283,398 270,409 "
    "C263,415 249,415 242,409 "
    "C229,398 215,375 206,350 "
    "C194,322 187,293 194,268 "
    "C200,247 224,236 256,236 Z"
)

# Lighter forehead and bridge, the highlight that gives the face its form.
BLAZE_LIGHT = (
    "M256,246 C276,246 292,253 296,268 "
    "C301,288 296,316 288,342 "
    "C282,362 271,382 262,392 "
    "C259,395 253,395 250,392 "
    "C241,382 230,362 224,342 "
    "C216,316 211,288 216,268 "
    "C220,253 236,246 256,246 Z"
)

# Dark blaze down the centre of the nose.
NOSE_STRIPE = (
    "M256,258 C266,258 273,263 275,273 "
    "C278,290 274,315 268,338 "
    "C264,353 260,368 256,376 "
    "C252,368 248,353 244,338 "
    "C238,315 234,290 237,273 "
    "C239,263 246,258 256,258 Z"
)

MUZZLE_PATCH = (
    "M256,360 C275,360 288,371 288,385 "
    "C288,400 274,410 256,410 "
    "C238,410 224,400 224,385 "
    "C224,371 237,360 256,360 Z"
)

BEARD_SHAPE = "M238,398 C233,424 241,452 256,468 C271,452 279,424 274,398 Z"

EAR_LEFT = "M214,290 C182,272 146,278 126,306 C143,329 184,331 210,318 Z"
EAR_LEFT_INNER = "M209,296 C186,285 160,289 146,306 C159,320 188,321 206,313 Z"


def ibex():
    return f"""
      <g>
        <!-- ears -->
        <g>
          <path d="{EAR_LEFT}" fill="{COAT_DARK}"/>
          <path d="{EAR_LEFT_INNER}" fill="{COAT_MID}" opacity="0.8"/>
          <g transform="translate({SIZE},0) scale(-1,1)">
            <path d="{EAR_LEFT}" fill="{COAT_DARK}"/>
            <path d="{EAR_LEFT_INNER}" fill="{COAT_MID}" opacity="0.8"/>
          </g>
        </g>

        <!-- beard -->
        <path d="{BEARD_SHAPE}" fill="{BEARD}"/>

        <!-- head, shaded from the sides inwards -->
        <path d="{HEAD}" fill="url(#coat)"/>
        <path d="{BLAZE_LIGHT}" fill="url(#blaze)" opacity="0.85"/>
        <path d="{NOSE_STRIPE}" fill="{BLAZE}" opacity="0.55"/>

        <!-- muzzle -->
        <path d="{MUZZLE_PATCH}" fill="{MUZZLE}"/>
        <path d="M256,384 C264,384 269,388 269,392 C269,397 263,400 256,400
                 C249,400 243,397 243,392 C243,388 248,384 256,384 Z"
              fill="{BLAZE}" opacity="0.35"/>
        <ellipse cx="245" cy="381" rx="5.5" ry="4" fill="{BLAZE}"/>
        <ellipse cx="267" cy="381" rx="5.5" ry="4" fill="{BLAZE}"/>

        <!-- eyes -->
        <g>
          <ellipse cx="227" cy="300" rx="19" ry="14" fill="{EYE_RING}" opacity="0.55"/>
          <ellipse cx="285" cy="300" rx="19" ry="14" fill="{EYE_RING}" opacity="0.55"/>
          <ellipse cx="227" cy="301" rx="14" ry="10" fill="#241608"/>
          <ellipse cx="285" cy="301" rx="14" ry="10" fill="#241608"/>
          <ellipse cx="227" cy="301" rx="10.5" ry="7" fill="#8A5A16"/>
          <ellipse cx="285" cy="301" rx="10.5" ry="7" fill="#8A5A16"/>
          <rect x="220.5" y="298.5" width="13" height="5" rx="2.5" fill="#120B04"/>
          <rect x="278.5" y="298.5" width="13" height="5" rx="2.5" fill="#120B04"/>
          <circle cx="222" cy="296" r="3.4" fill="#FFFFFF" opacity="0.95"/>
          <circle cx="280" cy="296" r="3.4" fill="#FFFFFF" opacity="0.95"/>
        </g>

        <!-- fur along the cheeks -->
        <g stroke="{COAT_DARK}" stroke-width="3" stroke-linecap="round"
           fill="none" opacity="0.4">
          <path d="M206,322 C214,332 218,344 220,356"/>
          <path d="M215,344 C222,353 226,364 228,374"/>
          <path d="M306,322 C298,332 294,344 292,356"/>
          <path d="M297,344 C290,353 286,364 284,374"/>
        </g>

        <!-- horns -->
        <g>
          <path d="{horn_outline()}" fill="url(#horn)" stroke="{HORN_DARK}"
                stroke-width="3" stroke-linejoin="round"/>
          <path d="{horn_shadow()}" fill="{HORN_DARK}" opacity="0.28"/>
          <g stroke="{HORN_DARK}" stroke-linecap="round" fill="none" opacity="0.85">
          {horn_ridges()}
          </g>
        </g>
        <g transform="translate({SIZE},0) scale(-1,1)">
          <path d="{horn_outline()}" fill="url(#horn)" stroke="{HORN_DARK}"
                stroke-width="3" stroke-linejoin="round"/>
          <path d="{horn_shadow()}" fill="{HORN_DARK}" opacity="0.28"/>
          <g stroke="{HORN_DARK}" stroke-linecap="round" fill="none" opacity="0.85">
          {horn_ridges()}
          </g>
        </g>
      </g>"""


# ---------------------------------------------------------------- rainbow ---

RAINBOW_CX, RAINBOW_CY = 256, 436
RAINBOW_OUTER = 222
RAINBOW_BAND = 13


def rainbow_bands():
    bands = []
    for index, colour in enumerate(RAINBOW):
        outer = RAINBOW_OUTER - index * RAINBOW_BAND
        inner = outer - RAINBOW_BAND
        d = (
            f"M{RAINBOW_CX - outer},{SIZE} L{RAINBOW_CX - outer},{RAINBOW_CY} "
            f"A{outer},{outer} 0 0 1 {RAINBOW_CX + outer},{RAINBOW_CY} "
            f"L{RAINBOW_CX + outer},{SIZE} L{RAINBOW_CX + inner},{SIZE} "
            f"L{RAINBOW_CX + inner},{RAINBOW_CY} "
            f"A{inner},{inner} 0 0 0 {RAINBOW_CX - inner},{RAINBOW_CY} "
            f"L{RAINBOW_CX - inner},{SIZE} Z"
        )
        bands.append(f'<path d="{d}" fill="{colour}"/>')
    return "\n      ".join(bands)


# ---------------------------------------------------------------- cartela ---

# Which squares on the little cartela are daubed, and in which colour.
CARTELA_MARKS = {
    (0, 1): "#FF3B30",
    (1, 3): "#0A84FF",
    (2, 2): "#FFCC00",
    (3, 0): "#34C759",
    (4, 4): "#AF52DE",
    (1, 1): "#FF9500",
}


def cartela(x, y, width, rotation):
    """A miniature 5x5 bingo card, tilted like it is lying on a table."""
    height = width * 1.02
    pad = width * 0.09
    cell = (width - pad * 2) / 5
    dot = cell * 0.34
    squares = []
    for row in range(5):
        for col in range(5):
            cx = pad + cell * (col + 0.5)
            cy = pad + cell * (row + 0.5)
            colour = CARTELA_MARKS.get((row, col))
            if row == 2 and col == 2:
                colour = "#FFCC00"
            squares.append(
                f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{dot:.1f}" '
                f'fill="{colour or "#C7CBD6"}"/>'
            )
    return f"""
      <g transform="translate({x},{y}) rotate({rotation})">
        <rect x="0" y="0" width="{width}" height="{height}" rx="{width * 0.08:.1f}"
              fill="#FFFFFF" stroke="#0B0D26" stroke-width="3" stroke-opacity="0.25"/>
        {"".join(squares)}
      </g>"""


# ------------------------------------------------------------- bingo balls ---


def ball(cx, cy, radius, colour, label):
    """A numbered bingo ball with a white face and a specular highlight."""
    face = radius * 0.64
    # Two digits have to be set smaller to stay inside the white face.
    digits = radius * (0.86 if len(label) == 1 else 0.62)
    digits_label = label
    return f"""
      <g>
        <circle cx="{cx}" cy="{cy}" r="{radius}" fill="{colour}"/>
        <circle cx="{cx}" cy="{cy}" r="{radius}" fill="url(#ballShade)"/>
        <circle cx="{cx}" cy="{cy}" r="{face:.1f}" fill="#FFFFFF"/>
        <g fill="#12142E">
          {text_path(digits_label, digits, cx, cy + digits * 0.35)}
        </g>
        <ellipse cx="{cx - radius * 0.34:.1f}" cy="{cy - radius * 0.55:.1f}"
                 rx="{radius * 0.26:.1f}" ry="{radius * 0.17:.1f}"
                 fill="#FFFFFF" opacity="0.55"/>
      </g>"""


# ------------------------------------------------------------------- build ---


def svg(with_wordmark=True, mark_scale=1.0, mark_shift_y=0.0, radius=112, ring=True):
    """Build the logo SVG.

    `with_wordmark` adds the BINGO lettering, which is only legible at the sizes
    the app itself renders. `mark_scale`/`mark_shift_y` pull the artwork into the
    centre safe circle Android crops a maskable icon to.
    """
    offset = (SIZE - SIZE * mark_scale) / 2
    transform = (
        f'transform="translate({offset:.1f},{offset + mark_shift_y:.1f}) '
        f'scale({mark_scale})"'
    )

    # Without the lettering the animal can take the space back.
    ibex_scale = 0.80 if with_wordmark else 0.90
    ibex_lift = 26 if with_wordmark else 10
    ibex_transform = (
        f'transform="translate(256,{40 - ibex_lift}) scale({ibex_scale}) '
        f'translate(-256,-40)"'
    )

    wordmark = ""
    if with_wordmark:
        wordmark = f"""
      <g>
        <rect x="84" y="428" width="344" height="62" rx="31" fill="#0B0D26" opacity="0.78"/>
        <g fill="url(#wordmark)">
          {text_path("BINGO", 48, 256, 475, letter_spacing=5)}
        </g>
      </g>"""

    ring_markup = (
        f'<rect x="8" y="8" width="{SIZE - 16}" height="{SIZE - 16}" '
        f'rx="{radius - 8}" ry="{radius - 8}" fill="none" stroke="url(#gold)" '
        f'stroke-width="7" opacity="0.8"/>'
        if ring
        else ""
    )

    balls_y = 392 if with_wordmark else 424
    ball_r = 33 if with_wordmark else 37

    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {SIZE} {SIZE}" width="{SIZE}" height="{SIZE}">
  <title>Besufikad Bingo</title>
  <defs>
    <linearGradient id="badge" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0" stop-color="{INK_DARK}"/>
      <stop offset="1" stop-color="{INK_LIGHT}"/>
    </linearGradient>
    <radialGradient id="glow" cx="0.5" cy="0.4" r="0.55">
      <stop offset="0" stop-color="#5B47A8" stop-opacity="0.5"/>
      <stop offset="1" stop-color="#5B47A8" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="gold" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFF0C4"/>
      <stop offset="0.45" stop-color="#F6C55F"/>
      <stop offset="1" stop-color="#D98E2B"/>
    </linearGradient>
    <linearGradient id="coat" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="{COAT_DARK}"/>
      <stop offset="0.32" stop-color="{COAT_MID}"/>
      <stop offset="0.68" stop-color="{COAT_MID}"/>
      <stop offset="1" stop-color="{COAT_DARK}"/>
    </linearGradient>
    <linearGradient id="blaze" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{COAT_LIGHT}"/>
      <stop offset="1" stop-color="{COAT_MID}" stop-opacity="0.2"/>
    </linearGradient>
    <linearGradient id="horn" x1="0.1" y1="0" x2="0.9" y2="1">
      <stop offset="0" stop-color="{HORN_LIGHT}"/>
      <stop offset="0.55" stop-color="{HORN_MID}"/>
      <stop offset="1" stop-color="{HORN_DARK}"/>
    </linearGradient>
    <radialGradient id="ballShade" cx="0.35" cy="0.3" r="0.85">
      <stop offset="0" stop-color="#FFFFFF" stop-opacity="0.35"/>
      <stop offset="0.6" stop-color="#000000" stop-opacity="0"/>
      <stop offset="1" stop-color="#000000" stop-opacity="0.35"/>
    </radialGradient>
    <linearGradient id="wordmark" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#FF3B30"/>
      <stop offset="0.25" stop-color="#FF9500"/>
      <stop offset="0.5" stop-color="#FFCC00"/>
      <stop offset="0.75" stop-color="#34C759"/>
      <stop offset="1" stop-color="#0A84FF"/>
    </linearGradient>
    <clipPath id="badgeClip">
      <rect x="0" y="0" width="{SIZE}" height="{SIZE}" rx="{radius}" ry="{radius}"/>
    </clipPath>
  </defs>

  <rect x="0" y="0" width="{SIZE}" height="{SIZE}" rx="{radius}" ry="{radius}" fill="url(#badge)"/>

  <g clip-path="url(#badgeClip)">
    <g {transform}>
      <rect x="0" y="0" width="{SIZE}" height="{SIZE}" fill="url(#glow)"/>

      <g opacity="0.95">
      {rainbow_bands()}
      </g>

      {cartela(4, 300, 116, -14)}
      {cartela(392, 310, 112, 12)}

      <g {ibex_transform}>
        {ibex()}
      </g>

      {ball(176, balls_y, ball_r, "#FF3B30", "7")}
      {ball(336, balls_y, ball_r, "#0A84FF", "21")}
      {ball(256, balls_y + 16, ball_r + 3, "#FFCC00", "42")}

      {wordmark}
    </g>
  </g>

  {ring_markup}
</svg>
"""


# ------------------------------------------------------------------ output ---

ANDROID_MIPMAPS = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

IOS_ICONS = {
    "Icon-App-20x20@1x.png": 20,
    "Icon-App-20x20@2x.png": 40,
    "Icon-App-20x20@3x.png": 60,
    "Icon-App-29x29@1x.png": 29,
    "Icon-App-29x29@2x.png": 58,
    "Icon-App-29x29@3x.png": 87,
    "Icon-App-40x40@1x.png": 40,
    "Icon-App-40x40@2x.png": 80,
    "Icon-App-40x40@3x.png": 120,
    "Icon-App-50x50@1x.png": 50,
    "Icon-App-50x50@2x.png": 100,
    "Icon-App-57x57@1x.png": 57,
    "Icon-App-57x57@2x.png": 114,
    "Icon-App-60x60@2x.png": 120,
    "Icon-App-60x60@3x.png": 180,
    "Icon-App-72x72@1x.png": 72,
    "Icon-App-72x72@2x.png": 144,
    "Icon-App-76x76@1x.png": 76,
    "Icon-App-76x76@2x.png": 152,
    "Icon-App-83.5x83.5@2x.png": 167,
    "Icon-App-1024x1024@1x.png": 1024,
}


def render(source, path, size, flatten=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    cairosvg.svg2png(
        bytestring=source.encode(), write_to=path, output_width=size, output_height=size
    )
    if flatten:
        # iOS rejects app icons that carry an alpha channel.
        image = Image.open(path).convert("RGBA")
        opaque = Image.new("RGB", image.size, INK_DARK)
        opaque.paste(image, mask=image.split()[3])
        opaque.save(path)


def main():
    full = svg(with_wordmark=True)
    icon = svg(with_wordmark=False, radius=48)
    maskable = svg(
        with_wordmark=False, mark_scale=0.66, mark_shift_y=-34, radius=0, ring=False
    )

    branding = os.path.join(ROOT, "assets", "branding")
    os.makedirs(branding, exist_ok=True)
    with open(os.path.join(branding, "besufikad_logo.svg"), "w") as handle:
        handle.write(full)
    with open(os.path.join(branding, "besufikad_icon.svg"), "w") as handle:
        handle.write(icon)

    render(full, os.path.join(ROOT, "assets", "images", "logo.png"), 1024)
    render(icon, os.path.join(ROOT, "assets", "images", "app_icon.png"), 1024)

    for folder, size in ANDROID_MIPMAPS.items():
        render(
            icon,
            os.path.join(ROOT, "android", "app", "src", "main", "res", folder, "ic_launcher.png"),
            size,
        )

    appicon = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for name, size in IOS_ICONS.items():
        render(icon, os.path.join(appicon, name), size, flatten=True)

    render(icon, os.path.join(ROOT, "web", "favicon.png"), 64)
    for size in (192, 512):
        render(icon, os.path.join(ROOT, "web", "icons", f"Icon-{size}.png"), size)
        render(maskable, os.path.join(ROOT, "web", "icons", f"Icon-maskable-{size}.png"), size)

    launch = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "LaunchImage.imageset")
    for name, size in (
        ("LaunchImage.png", 256),
        ("LaunchImage@2x.png", 512),
        ("LaunchImage@3x.png", 768),
        ("logo.png", 512),
    ):
        render(full, os.path.join(launch, name), size)

    print("Generated Besufikad Bingo branding.")


if __name__ == "__main__":
    main()
