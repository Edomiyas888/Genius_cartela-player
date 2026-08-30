import 'package:flutter/material.dart';

/// Single source of truth for how the app names and presents itself.
const String kAppName = 'Besufikad Bingo';
const String kAppTagline = 'Besufikad Bingo - For Fun In Life';
const String kVenueName = 'ጥር 7 ጃምቦ ሀዉስ';
const String kManagerName = 'ስራአስኪያጅ ምኑየለት ጤናዉ';
const String kContactPrompt = 'ስለ መስተንግዶአችን አስተያየት ካሎት በዚህ ቁጥር ይደዉሉ';
const String kContactPhone = '0929252131';
const String kContactPhoneDial = '+251929252131';
const String kCopyright = 'Developed by Habeshagaming.com @Copyright 2024';

/// The full logo - the pair of Waliya ibex in a gold medallion, under a
/// rainbow, over the bingo balls and the BINGO wordmark. Composed by
/// tool/compose_logo.py from assets/images/waliya_pair.png; use it where it
/// renders large enough to read the lettering.
const String kLogoAsset = 'assets/images/logo.png';

/// The same medallion and rainbow without the balls or lettering, for small
/// placements like the app bar where those would only turn to mush.
const String kLogoMarkAsset = 'assets/images/app_icon.png';

/// Highest number of cards a single player may track at once.
const int kMaxCards = 10;

const Color kBrandOrange = Color(0xFFF69C12);
const Color kBrandInk = Color(0xFF0E1030);
const Color kBrandGold = Color(0xFFF6C55F);

/// Cell states on a card.
const Color kCellIdle = Color(0xFFCBCBCB);
const Color kCellMarked = Color(0xFF00A2FF);
const Color kCellWinning = Color(0xFF4CAF50);
