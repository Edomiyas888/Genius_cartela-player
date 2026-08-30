import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './branding.dart';
import './constant.dart';

void main() {
  runApp(const MyApp());
}

/// Column letters, in board order.
const List<String> kColumns = ['b', 'i', 'n', 'g', 'o'];

/// Gap between two card tiles, both across and down.
const double _kTileSpacing = 8;

/// Padding around the whole board.
const double _kBoardPadding = 8;

/// Card counts that will not fit on screen at a size worth reading. They are
/// laid out as though only [_kCardsOnScreen] were open, and the rest of the
/// rows are reached by scrolling.
const Set<int> _kScrollingCounts = <int>{8, 10};
const int _kCardsOnScreen = 6;

/// Heights of the header and footer strips of a card, as a multiple of one
/// cell. They are fixed so a card's height is a pure function of its width and
/// the board can be sized to fit the screen without measuring anything.
const double _kHeaderRatio = 0.9;
const double _kFooterRatio = 0.95;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<TextEditingController> _controllers =
      List<TextEditingController>.generate(
          kMaxCards, (_) => TextEditingController(),
          growable: false);
  final List<Map<String, dynamic>?> _cards = List<Map<String, dynamic>?>.filled(
    kMaxCards,
    null,
  );
  final List<bool> _isCardOpen = List<bool>.filled(kMaxCards, false);
  final List<bool> _lookupFailed = List<bool>.filled(kMaxCards, false);

  /// Marks are stored per *number*, never per card, so calling a number lights
  /// it up on every open card that happens to carry it.
  final Set<int> _selectedNumbers = <int>{};

  /// How many cards the player is tracking right now. Always even, and never
  /// more than [kMaxCards].
  int _cardCount = 2;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // --------------------------------------------------------------- marking --

  bool _isNumberSelected(int number) =>
      number == 0 || _selectedNumbers.contains(number);

  void _toggleNumber(int number) {
    if (number == 0) return;
    setState(() {
      if (!_selectedNumbers.remove(number)) {
        _selectedNumbers.add(number);
      }
    });
  }

  void _clearSelectedNumbers() {
    setState(_selectedNumbers.clear);
  }

  // ------------------------------------------------------- winning patterns --

  /// The number printed at [row], [col]. Columns are stored letter by letter,
  /// so the board's (row, column) has to be read the other way round.
  int _numberAt(Map<String, dynamic> cardData, int row, int col) =>
      cardData[kColumns[col]][row] as int;

  /// Whether every cell of [cells] - each an (row, col) pair - is marked.
  bool _isPatternComplete(
    Map<String, dynamic> cardData,
    List<List<int>> cells,
  ) {
    for (final List<int> cell in cells) {
      if (!_isNumberSelected(_numberAt(cardData, cell[0], cell[1]))) {
        return false;
      }
    }
    return true;
  }

  /// The winning patterns that pass through [row], [col]: its row, its column,
  /// whichever diagonals it lies on, and the four corners if it is one. A cell
  /// only has to belong to one completed pattern to go gold.
  List<List<List<int>>> _patternsThrough(int row, int col) {
    final List<List<List<int>>> patterns = <List<List<int>>>[
      <List<int>>[for (int c = 0; c < 5; c++) <int>[row, c]],
      <List<int>>[for (int r = 0; r < 5; r++) <int>[r, col]],
    ];
    if (row == col) {
      patterns.add(<List<int>>[for (int i = 0; i < 5; i++) <int>[i, i]]);
    }
    if (row + col == 4) {
      patterns.add(<List<int>>[for (int i = 0; i < 5; i++) <int>[i, 4 - i]]);
    }
    if ((row == 0 || row == 4) && (col == 0 || col == 4)) {
      patterns.add(const <List<int>>[
        <int>[0, 0],
        <int>[0, 4],
        <int>[4, 0],
        <int>[4, 4],
      ]);
    }
    return patterns;
  }

  bool _isCellInWinningPattern(
      Map<String, dynamic> cardData, int row, int col) {
    for (final List<List<int>> pattern in _patternsThrough(row, col)) {
      if (_isPatternComplete(cardData, pattern)) return true;
    }
    return false;
  }

  Color _cellColor(
      Map<String, dynamic> cardData, int row, int col, int number) {
    if (_isCellInWinningPattern(cardData, row, col)) return kCellWinning;
    if (_isNumberSelected(number)) return kCellMarked;
    return kCellIdle;
  }

  // ------------------------------------------------------------ card slots --

  void _openCard(int index) {
    final int wanted = int.tryParse(_controllers[index].text.trim()) ?? -1;
    Map<String, dynamic>? match;
    for (final Map<String, dynamic> candidate in cards) {
      if (candidate['cardname'] == wanted) {
        match = candidate;
        break;
      }
    }
    setState(() {
      _cards[index] = match;
      _isCardOpen[index] = match != null;
      _lookupFailed[index] = match == null;
    });
  }

  void _closeCard(int index) {
    setState(() {
      _cards[index] = null;
      _isCardOpen[index] = false;
      _lookupFailed[index] = false;
    });
  }

  void _setCardCount(int count) {
    setState(() => _cardCount = count);
  }

  // ------------------------------------------------------------------ view --

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The board is sized to the visible area, so the keyboard has to float
      // over it rather than shrink it and squash the cards.
      resizeToAvoidBottomInset: false,
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildBoard()),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBrandOrange,
      titleSpacing: 8,
      title: Row(
        children: [
          Image.asset(
            kLogoMarkAsset,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  kAppName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kBrandInk,
                  ),
                ),
                GestureDetector(
                  onTap: _launchPhoneCall,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone, size: 12, color: kBrandInk),
                      SizedBox(width: 4),
                      Text(
                        kContactPhone,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kBrandInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Clear all marks',
          icon: const Icon(Icons.refresh, color: kBrandInk),
          onPressed: _clearSelectedNumbers,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _cardCount,
              dropdownColor: Colors.white,
              iconEnabledColor: kBrandInk,
              style: const TextStyle(
                color: kBrandInk,
                fontWeight: FontWeight.bold,
              ),
              onChanged: (int? value) {
                if (value != null) _setCardCount(value);
              },
              // A single card, then the even counts the game is normally
              // played in.
              items: <int>[
                1,
                for (int i = 1; i <= kMaxCards ~/ 2; i++) i * 2,
              ]
                  .map((int count) => DropdownMenuItem<int>(
                        value: count,
                        child: Text(count == 1 ? '1 card' : '$count cards'),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- board fit --

  /// Inner padding of a card tile, which doubles as the gap between cells.
  double _tileGap(double width) => (width * 0.025).clamp(3.0, 10.0);

  /// Side of one numbered circle on a tile [width] wide.
  double _cellFor(double width) {
    final double gap = _tileGap(width);
    return (width - gap * 6) / 5;
  }

  /// The height a card tile [width] wide needs. Kept in step with
  /// [_buildOpenCard], which lays every strip out at exactly these sizes.
  double _tileHeightFor(double width) {
    final double gap = _tileGap(width);
    final double cell = _cellFor(width);
    return gap * 2 + // container padding
        cell * _kHeaderRatio + // BINGO letters
        gap +
        cell * 5 + gap * 4 + // the 5x5 grid
        gap +
        cell * _kFooterRatio; // card number and Back
  }

  /// Widest tile whose height still fits in [height], capped at [maxWidth].
  double _widthForHeight(double height, double maxWidth) {
    double low = 0;
    double high = maxWidth;
    for (int i = 0; i < 24; i++) {
      final double mid = (low + high) / 2;
      if (_tileHeightFor(mid) <= height) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }

  /// How many cards the board is sized around. Below this the player sees
  /// every open card at once; above it they scroll.
  int get _cardsToFit =>
      _kScrollingCounts.contains(_cardCount) ? _kCardsOnScreen : _cardCount;

  /// Picks the grid shape that makes the cards as large as possible while
  /// keeping [count] of them on screen.
  ({int columns, double tileWidth}) _bestGrid(
      double width, double height, int count) {
    int bestColumns = 1;
    double bestWidth = 0;
    for (int columns = 1; columns <= count; columns++) {
      final int rows = (count / columns).ceil();
      final double tileWidth =
          (width - _kTileSpacing * (columns - 1)) / columns;
      final double tileHeight = (height - _kTileSpacing * (rows - 1)) / rows;
      if (tileWidth <= 0 || tileHeight <= 0) continue;
      final double fitted =
          math.min(tileWidth, _widthForHeight(tileHeight, tileWidth));
      if (fitted > bestWidth) {
        bestWidth = fitted;
        bestColumns = columns;
      }
    }
    return (columns: bestColumns, tileWidth: math.max(bestWidth, 1));
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double available = constraints.maxWidth - _kBoardPadding * 2;
        final double vertical = constraints.maxHeight - _kBoardPadding * 2;
        final grid = _bestGrid(available, vertical, _cardsToFit);
        // Every card gets a slot in the same grid; only the rows past the
        // sixth card fall below the fold.
        final int rows = (_cardCount / grid.columns).ceil();
        final bool scrolls = _cardCount > _cardsToFit;
        final Widget board = Padding(
          padding: const EdgeInsets.all(_kBoardPadding),
          child: Column(
            // A scrolling board is unbounded, so it has to shrink-wrap its
            // rows rather than centre them in a height it does not have.
            mainAxisSize: scrolls ? MainAxisSize.min : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(rows, (int row) {
              final int first = row * grid.columns;
              final int last = math.min(first + grid.columns, _cardCount);
              return Padding(
                padding: EdgeInsets.only(
                    bottom: row < rows - 1 ? _kTileSpacing : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (int index = first; index < last; index++) ...[
                      if (index > first) const SizedBox(width: _kTileSpacing),
                      _buildCardTile(index, grid.tileWidth),
                    ],
                  ],
                ),
              );
            }),
          ),
        );
        return scrolls ? SingleChildScrollView(child: board) : board;
      },
    );
  }

  Widget _buildCardTile(int index, double width) {
    final Map<String, dynamic>? cardData = _cards[index];
    final bool isOpen = _isCardOpen[index] && cardData != null;
    final double gap = _tileGap(width);
    final double cell = _cellFor(width);
    return SizedBox(
      width: width,
      height: _tileHeightFor(width),
      child: Container(
        padding: EdgeInsets.all(gap),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: isOpen
            ? _buildOpenCard(index, cardData, cell, gap)
            : _buildCardPicker(index, width - gap * 2, gap),
      ),
    );
  }

  Widget _buildOpenCard(
    int index,
    Map<String, dynamic> cardData,
    double cell,
    double gap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: cell * _kHeaderRatio,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(5, (int col) {
              return SizedBox(
                width: cell,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    kColumns[col].toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cell * 0.72,
                      color: kBrandInk,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        SizedBox(height: gap),
        for (int row = 0; row < 5; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(5, (int col) {
              return _buildCell(cardData, row, col, cell);
            }),
          ),
          if (row < 4) SizedBox(height: gap),
        ],
        SizedBox(height: gap),
        SizedBox(
          height: cell * _kFooterRatio,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No. ${cardData['cardname']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: cell * 0.42,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _closeCard(index),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: cell * 0.42,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCell(
    Map<String, dynamic> cardData,
    int row,
    int col,
    double size,
  ) {
    final int number = _numberAt(cardData, row, col);
    final bool isSelected = _isNumberSelected(number);
    final Color fill = _cellColor(cardData, row, col, number);
    final bool hasWon = fill == kCellWinning;
    // Gold is far too light to carry the white a marked cell uses.
    final Color ink = hasWon
        ? kBrandInk
        : (isSelected ? Colors.white : Colors.black);
    return GestureDetector(
      onTap: () => _toggleNumber(number),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          shape: BoxShape.circle,
        ),
        // The free space uses a bundled Material icon rather than a star
        // glyph, which not every platform font can render.
        child: number == 0
            ? Icon(Icons.star,
                size: size * 0.52, color: hasWon ? kBrandInk : kBrandOrange)
            : FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: ink,
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  /// The empty state of a slot. It is scaled down when the tile is too short
  /// for the logo and the input at their natural size, which keeps the picker
  /// inside the tile however many cards are on screen.
  Widget _buildCardPicker(int index, double width, double gap) {
    final double logoHeight = math.min(84, width * 0.42);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(kLogoAsset, height: logoHeight, fit: BoxFit.contain),
            SizedBox(height: gap),
            Text(
              'Card ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onSubmitted: (_) => _openCard(index),
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Cartela number',
                isDense: true,
              ),
            ),
            if (_lookupFailed[index])
              Padding(
                padding: EdgeInsets.only(top: gap),
                child: const Text(
                  'No card with that number',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            SizedBox(height: gap * 1.5),
            GestureDetector(
              onTap: () => _openCard(index),
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(17),
                  color: const Color.fromARGB(255, 255, 98, 0),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Play',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: kContactPhoneDial);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Could not start a call to $kContactPhone')),
      );
    }
  }
}
