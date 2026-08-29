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

  /// How many cards the player is tracking right now (1 to [kMaxCards]).
  int _cardCount = 1;

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

  /// Numbers printed on more than one of the currently open cards. Those cells
  /// get a ring so it is obvious why marking one of them lit up two boards.
  Set<int> _numbersOnMultipleCards() {
    final Map<int, int> occurrences = <int, int>{};
    for (int index = 0; index < _cardCount; index++) {
      final Map<String, dynamic>? cardData = _cards[index];
      if (cardData == null || !_isCardOpen[index]) continue;
      for (final String key in kColumns) {
        for (final dynamic value in cardData[key] as List<dynamic>) {
          final int number = value as int;
          if (number == 0) continue;
          occurrences[number] = (occurrences[number] ?? 0) + 1;
        }
      }
    }
    return occurrences.entries
        .where((MapEntry<int, int> entry) => entry.value > 1)
        .map((MapEntry<int, int> entry) => entry.key)
        .toSet();
  }

  // ----------------------------------------------------------- line checks --

  bool _isRowComplete(Map<String, dynamic> cardData, int row) {
    for (final String key in kColumns) {
      if (!_isNumberSelected(cardData[key][row] as int)) return false;
    }
    return true;
  }

  bool _isColComplete(Map<String, dynamic> cardData, int col) {
    final List<dynamic> column = cardData[kColumns[col]] as List<dynamic>;
    for (int row = 0; row < 5; row++) {
      if (!_isNumberSelected(column[row] as int)) return false;
    }
    return true;
  }

  bool _isCellInFullLine(Map<String, dynamic> cardData, int row, int col) =>
      _isRowComplete(cardData, row) || _isColComplete(cardData, col);

  Color _cellColor(
      Map<String, dynamic> cardData, int row, int col, int number) {
    if (_isCellInFullLine(cardData, row, col)) return kCellWinning;
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
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [_buildBoard(), _buildFooter()],
          ),
        ),
      ),
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
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kAppName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: kBrandInk,
                  ),
                ),
                Text(
                  kVenueName,
                  style: TextStyle(fontSize: 11, color: kBrandInk),
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
              items: List<DropdownMenuItem<int>>.generate(kMaxCards, (int i) {
                final int count = i + 1;
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(count == 1 ? '1 card' : '$count cards'),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  /// How many cards fit side by side without squeezing the numbers illegibly.
  int _columnCount(double width) {
    if (_cardCount == 1) return 1;
    final int fits = (width / 190).floor().clamp(1, 5);
    return math.min(fits, _cardCount);
  }

  Widget _buildBoard() {
    final Set<int> sharedNumbers = _numbersOnMultipleCards();
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        const double spacing = 10;
        const double padding = 8;
        final double available = constraints.maxWidth - padding * 2;
        final int columns = _columnCount(available);
        final double tileWidth =
            (available - spacing * (columns - 1)) / columns;
        return Padding(
          padding: const EdgeInsets.all(padding),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            alignment: WrapAlignment.center,
            children: List<Widget>.generate(_cardCount, (int index) {
              return SizedBox(
                width: tileWidth,
                child: _buildCardTile(index, sharedNumbers),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCardTile(int index, Set<int> sharedNumbers) {
    final Map<String, dynamic>? cardData = _cards[index];
    final bool isOpen = _isCardOpen[index] && cardData != null;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double gap = (constraints.maxWidth * 0.025).clamp(3.0, 10.0);
        final double cell = (constraints.maxWidth - gap * 6) / 5;
        return Container(
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
              ? _buildOpenCard(index, cardData, sharedNumbers, cell, gap)
              : _buildCardPicker(index, constraints.maxWidth, gap),
        );
      },
    );
  }

  Widget _buildOpenCard(
    int index,
    Map<String, dynamic> cardData,
    Set<int> sharedNumbers,
    double cell,
    double gap,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(5, (int col) {
            return SizedBox(
              width: cell,
              child: Text(
                kColumns[col].toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: cell * 0.72,
                  color: kBrandInk,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: gap),
        for (int row = 0; row < 5; row++) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(5, (int col) {
              return _buildCell(cardData, row, col, cell, sharedNumbers);
            }),
          ),
          if (row < 4) SizedBox(height: gap),
        ],
        SizedBox(height: gap),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'No. ${cardData['cardname']}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () => _closeCard(index),
              child: const Text('Back'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCell(
    Map<String, dynamic> cardData,
    int row,
    int col,
    double size,
    Set<int> sharedNumbers,
  ) {
    final int number = cardData[kColumns[col]][row] as int;
    final bool isSelected = _isNumberSelected(number);
    final bool isShared = sharedNumbers.contains(number);
    return GestureDetector(
      onTap: () => _toggleNumber(number),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _cellColor(cardData, row, col, number),
          shape: BoxShape.circle,
          border: isShared
              ? Border.all(color: kBrandOrange, width: size * 0.08)
              : null,
        ),
        // The free space uses a bundled Material icon rather than a star
        // glyph, which not every platform font can render.
        child: number == 0
            ? Icon(Icons.star, size: size * 0.52, color: kBrandOrange)
            : Text(
                '$number',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildCardPicker(int index, double tileWidth, double gap) {
    final double logoHeight = math.min(84, tileWidth * 0.42);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(kLogoAsset, height: logoHeight, fit: BoxFit.contain),
        SizedBox(height: gap),
        Text(
          _cardCount == 1 ? 'Enter a Number' : 'Card ${index + 1}',
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
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      color: kBrandOrange,
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Image.asset(kLogoAsset, height: 76, fit: BoxFit.contain),
          const SizedBox(height: 8),
          const Text(
            kAppName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: kBrandInk,
            ),
          ),
          const SizedBox(height: 8),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            children: [
              Text(kContactPrompt),
              Text(kManagerName, style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                kContactPhone,
                style: TextStyle(
                  color: Color.fromARGB(255, 250, 7, 7),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.phone, size: 20),
                onPressed: _launchPhoneCall,
              ),
            ],
          ),
          const Divider(),
          const Text(
            kCopyright,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 23, 22, 22),
              fontSize: 14.0,
            ),
          ),
        ],
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
