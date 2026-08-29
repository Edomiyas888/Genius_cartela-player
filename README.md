# Besufikad Bingo

Besufikad Bingo is the cartela (bingo card) player used at ጥር 7 ጃምቦ ሀዉስ. A
player looks up their printed cartela by number and marks the numbers as they
are called.

## Features

- Track **1 to 10 cartelas at once** from the card-count selector in the app bar.
- Marks are stored per *number*, so tapping a called number marks it on **every**
  open cartela that carries it. Numbers printed on more than one open cartela are
  ringed in orange so it is clear which marks will travel.
- Completed rows and columns turn green automatically.
- "Clear all marks" in the app bar resets the round without reloading cartelas.

## Branding

The Waliya (walia ibex) and rainbow logo is drawn in code so every icon stays in
sync. To change it, edit `tool/generate_logo.py` and re-run:

```bash
pip install cairosvg pillow
python3 tool/generate_logo.py
```

That rewrites `assets/branding/besufikad_logo.svg`, the in-app artwork, the
Android mipmaps, the iOS `AppIcon` set and the web icons.

## Running

```bash
flutter pub get
flutter run
```

Cartela data lives in `lib/constant.dart`; naming, contact details and the card
limit live in `lib/branding.dart`.
