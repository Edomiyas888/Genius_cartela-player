#!/usr/bin/env python3
"""Cut the platform icons out of the composed logo.

tool/compose_logo.py builds the two in-app lockups; this fans them out to every
launcher slot the project ships, so a change to the mark reaches the whole app
in two commands:

    python3 tool/compose_logo.py
    python3 tool/render_icons.py

The app-bar mark feeds the launcher icons and the full lockup feeds the iOS
launch image, which renders large enough for the wordmark.
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PIL import Image

import compose_logo

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "assets", "images")

INK_DARK = (11, 13, 38)

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

def write(source, path, size, flatten=False):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    image = source.resize((size, size), Image.LANCZOS)
    if flatten:
        # iOS rejects app icons that carry an alpha channel.
        opaque = Image.new("RGB", image.size, INK_DARK)
        opaque.paste(image, mask=image.split()[3])
        image = opaque
    image.save(path)


def main():
    icon = Image.open(os.path.join(IMAGES, "app_icon.png")).convert("RGBA")
    full = Image.open(os.path.join(IMAGES, "logo.png")).convert("RGBA")
    mask = compose_logo.build("maskable")

    for folder, size in ANDROID_MIPMAPS.items():
        write(
            icon,
            os.path.join(ROOT, "android", "app", "src", "main", "res", folder, "ic_launcher.png"),
            size,
        )

    appicon = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for name, size in IOS_ICONS.items():
        write(icon, os.path.join(appicon, name), size, flatten=True)

    write(icon, os.path.join(ROOT, "web", "favicon.png"), 64)
    for size in (192, 512):
        write(icon, os.path.join(ROOT, "web", "icons", f"Icon-{size}.png"), size)
        write(mask, os.path.join(ROOT, "web", "icons", f"Icon-maskable-{size}.png"), size)

    launch = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "LaunchImage.imageset")
    for name, size in (
        ("LaunchImage.png", 256),
        ("LaunchImage@2x.png", 512),
        ("LaunchImage@3x.png", 768),
        ("logo.png", 512),
    ):
        write(full, os.path.join(launch, name), size)

    print("Rendered Android, iOS and web icons.")


if __name__ == "__main__":
    main()
