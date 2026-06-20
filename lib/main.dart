import 'package:flutter/material.dart';
import './constant.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Genius Bingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _numberController1 = TextEditingController();
  final TextEditingController _numberController2 = TextEditingController();
  final TextEditingController _numberController3 = TextEditingController();
  final TextEditingController _numberController4 = TextEditingController();
  final TextEditingController _numberController5 = TextEditingController();
  String? cardName;
  Map<String, dynamic>? card;
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  Map<String, dynamic>? card3;

  List<int>? cardDetails;
  List<int>? cardDetails1;
  List<int>? cardDetails2;

  List<int>? cardDetails3;

  List<bool> _isTablePressed = [false, false, false, false];
  int isFourCard = 1; // Tracks pressed tables

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFF69C12),
          title: Row(
            children: [
              Column(
                children: [
                  // Text(
                  //   'ከእኛ ጋር ኤጅንት ሆነው መስራት ከ ፈለጉ',
                  //   style: TextStyle(
                  //       color: Color.fromARGB(255, 0, 0, 0), fontSize: 13),
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      Image.asset(
                        'assets/images/bb.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      Text(
                        'ጥር 7 ጃምቦ ሀዉስ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 58, 58, 57),
                            fontSize: 17),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
              )
            ],
          ),
          actions: [
            DropdownButton<String>(
              value: isFourCard == 1
                  ? '1 card'
                  : isFourCard == 2
                      ? '2 cards'
                      : '4 cards',
              onChanged: (String? newValue) {
                // Handle dropdown item selection
                if (newValue == '1 card') {
                  setState(() {
                    isFourCard = 1;
                  });
                } else if (newValue == '2 cards') {
                  setState(() {
                    isFourCard = 2;
                  });
                } else if (newValue == '4 cards') {
                  setState(() {
                    isFourCard = 3;
                  });
                }
              },
              items: <String>['1 card', '2 cards', '4 cards']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: ClampingScrollPhysics(), // Prevent overflow error
          child: Column(
            children: [
              isFourCard == 1
                  ? Container(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight -
                          100,
                      child: _buildTwoNumbers2(1, _numberController))
                  : Container(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight -
                          0,
                      child: isFourCard == 3
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      _buildNumber(0, _numberController),
                                      _buildNumber(1, _numberController1),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Flex(
                                    direction: Axis.vertical,
                                    children: [
                                      _buildNumber(2, _numberController4),
                                      _buildNumber(3, _numberController5),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildTwoNumbers(0, _numberController),
                                  _buildTwoNumbers(1, _numberController1),
                                ],
                              ),
                            ),
                    ),
              // Footer Widget
              Container(
                // Adjust color as per your requirement

                width: MediaQuery.of(context).size.width,
                color: Color(0xFFF69C12),
                padding: EdgeInsets.all(10.0),
                child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/bb.png',
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      // Container(
                      //   width: MediaQuery.of(context).size.width,
                      //   decoration: BoxDecoration(color: Color(0x006600)),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Text('Phone: 0973817087'),
                      //     ],
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text('ስለ መስተንግዶአችን አስተያየት ካሎት በዚህ ቁጥር ይደዉሉ '),
                            Text(
                              'ስራአስኪያጅ ምኑየለት ጤናዉ',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '0911702828',
                            style: TextStyle(
                                color: Color.fromARGB(255, 250, 7, 7),
                                fontSize: 15),
                          ),
                          IconButton(
                            icon: Icon(Icons.phone, size: 20), // Phone icon
                            onPressed: _launchPhoneCall,
                          ),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     IconButton(
                      //       icon: Icon(Icons.phone, size: 10), // Phone icon
                      //       onPressed: _launchPhoneCall,
                      //     ),
                      //     SizedBox(width: 20),
                      //     IconButton(
                      //       icon: SizedBox(
                      //         height: 20,
                      //         child: Image.asset(
                      //           'assets/images/bb.png',
                      //           fit: BoxFit.fitHeight,
                      //         ),
                      //       ), // Replace with your Telegram logo image
                      //       iconSize: 100, // Adjust icon size as needed
                      //       onPressed: _launchTelegram,
                      //     ),
                      //     // Add spacing between icons
                      //   ],
                      // ),
                      Divider(),
                      const Text(
                        'Developed by Habeshagaming.com @Copyright 2024',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 22, 22),
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  void _launchTelegram() async {
    const telegramUrl = 'tg://resolve?domain=crownbingo'; // Telegram URI scheme
    const webUrl = 'https://t.me/crownbingo'; // Telegram website URL
    try {
      if (await canLaunch(telegramUrl)) {
        await launch(telegramUrl);
      } else {
        throw 'Telegram app not installed';
      }
    } catch (e) {
      print('Error launching Telegram: $e');
      // Fallback to opening the Telegram website in a browser
      try {
        await launch(webUrl);
      } catch (e) {
        print('Error launching Telegram website: $e');
        // Handle the error gracefully
      }
    }
  }

  void _launchPhoneCall() async {
    const phoneNumber = 'tel:+251911702828'; // Replace with your phone number
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Widget _buildTwoNumbers(int tableIndex, TextEditingController x) {
    void checkNumber() {
      final int insertedNumber = int.tryParse(x.text) ?? 0;
      for (final currentCard in cards) {
        final cardNumber = currentCard['cardname'];
        if (cardNumber == insertedNumber) {
          setState(() {
            cardName = cardNumber.toString();
            if (tableIndex == 1) {
              card1 = currentCard;
              cardDetails1 = null;
            } else {
              card = currentCard;
              cardDetails = null;
            }
          });
          return;
        }
      }
      setState(() {
        cardName = null;
        card = null;
        cardDetails = null;
        cardDetails1 = null;
      });
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isTablePressed[tableIndex] &&
                  ((tableIndex == 0 && card != null) ||
                      (tableIndex == 1 && card1 != null) ||
                      (tableIndex == 2 && card2 != null) ||
                      (tableIndex == 3 && card3 != null))) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLabel('B'),
                    _buildLabel('I'),
                    _buildLabel('N'),
                    _buildLabel('G'),
                    _buildLabel('O'),
                  ],
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: MediaQuery.of(context).size.width /
                            250, // Adjust button size
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final row = index ~/ 5;
                        final col = index % 5;
                        final key = ['b', 'i', 'n', 'g', 'o'][col];
                        final number = tableIndex == 0
                            ? card![key][row]
                            : tableIndex == 1
                                ? card1![key][row]
                                : tableIndex == 2
                                    ? card2![key][row]
                                    : card3![key][row];
                        final bool isSelected = tableIndex == 0
                            ? (cardDetails?.contains(number) ?? false)
                            : tableIndex == 1
                                ? (cardDetails1?.contains(number) ?? false)
                                : tableIndex == 2
                                    ? (cardDetails2?.contains(number) ?? false)
                                    : (cardDetails3?.contains(number) ?? false);
                        return GestureDetector(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isSelected
                                    ? Color.fromARGB(255, 0, 162, 255)
                                    : const Color.fromARGB(255, 203, 203, 203)),
                            child: Center(
                              child: Text(
                                number == 0 ? '⭐️' : number.toString(),
                                style: TextStyle(
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                  fontSize: 17, // Adjust button font size
                                  fontWeight:
                                      FontWeight.bold, // Make the text bold
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              if (tableIndex == 0) {
                                if (cardDetails == null) {
                                  cardDetails = [];
                                }
                                if (isSelected) {
                                  cardDetails!.remove(number);
                                } else {
                                  cardDetails!.add(number);
                                }
                              } else {
                                if (cardDetails1 == null) {
                                  cardDetails1 = [];
                                }
                                if (isSelected) {
                                  cardDetails1!.remove(number);
                                } else {
                                  cardDetails1!.add(number);
                                }
                              }
                            });
                          },
                        );
                        //  ElevatedButton(
                        //   onPressed: () {
                        //     setState(() {
                        //       if (tableIndex == 0) {
                        //         if (cardDetails == null) {
                        //           cardDetails = [];
                        //         }
                        //         if (isSelected) {
                        //           cardDetails!.remove(number);
                        //         } else {
                        //           cardDetails!.add(number);
                        //         }
                        //       } else {
                        //         if (cardDetails1 == null) {
                        //           cardDetails1 = [];
                        //         }
                        //         if (isSelected) {
                        //           cardDetails1!.remove(number);
                        //         } else {
                        //           cardDetails1!.add(number);
                        //         }
                        //       }
                        //     });
                        //   },
                        //   style: ButtonStyle(
                        //     backgroundColor: MaterialStateProperty.all<Color>(
                        //       isSelected ? Colors.green : Colors.grey,
                        //     ),
                        //   ),
                        //   child: Text(
                        //     number.toString(),
                        //     style: TextStyle(
                        //       color: isSelected ? Colors.white : Colors.black,
                        //       fontSize: 17, // Adjust button font size
                        //       fontWeight: FontWeight.bold, // Make the text bold
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(' Number: ${x.text}'),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          cardName = null;

                          if (tableIndex == 0) {
                            card = null;
                            cardDetails = null;
                          } else {
                            card1 = null;

                            cardDetails1 = null;
                          }
                          _isTablePressed[tableIndex] = false;
                        });
                      },
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Clear the selected numbers and related variables
                          if (tableIndex == 0) {
                            cardDetails = null;
                          } else if (tableIndex == 1) {
                            cardDetails1 = null;
                          } else if (tableIndex == 2) {
                            cardDetails2 = null;
                          } else if (tableIndex == 3) {
                            cardDetails3 = null;
                          }
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ] else ...[
                TextField(
                  controller: x,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                  decoration: const InputDecoration(
                    labelText: 'Enter a number',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.2), // Shadow color
                            blurRadius: 6, // Spread radius
                            offset:
                                Offset(0, 3), // Offset in x and y directions
                          ),
                        ],
                        borderRadius: BorderRadius.circular(17),
                        color: Color.fromARGB(255, 255, 98, 0)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Play',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                  ),
                  onTap: () {
                    setState(() {
                      _isTablePressed[tableIndex] = true;
                    });
                    checkNumber();
                  },
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     setState(() {
                //       _isTablePressed[tableIndex] = true;
                //     });
                //     checkNumber();
                //   },
                //   child: const Text('Play'),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 35,
      ),
    );
  }

  Widget _buildTwoNumbers2(int tableIndex, TextEditingController x) {
    void checkNumber() {
      final int insertedNumber = int.tryParse(x.text) ?? 0;
      for (final currentCard in cards) {
        final cardNumber = currentCard['cardname'];
        if (cardNumber == insertedNumber) {
          setState(() {
            cardName = cardNumber.toString();
            if (tableIndex == 1) {
              card1 = currentCard;
              cardDetails1 = null;
            } else {
              card = currentCard;
              cardDetails = null;
            }
          });
          return;
        }
      }
      setState(() {
        cardName = null;
        card = null;
        cardDetails = null;
        cardDetails1 = null;
      });
    }

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isTablePressed[tableIndex] &&
                      ((tableIndex == 0 && card != null) ||
                          (tableIndex == 1 && card1 != null) ||
                          (tableIndex == 2 && card2 != null) ||
                          (tableIndex == 3 && card3 != null))) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildLabel('B'),
                        _buildLabel('I'),
                        _buildLabel('N'),
                        _buildLabel('G'),
                        _buildLabel('O'),
                      ],
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        child: GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            childAspectRatio:
                                MediaQuery.of(context).size.width /
                                    400, // Adjust button size
                          ),
                          itemCount: 25,
                          itemBuilder: (context, index) {
                            final row = index ~/ 5;
                            final col = index % 5;
                            final key = ['b', 'i', 'n', 'g', 'o'][col];
                            final number = tableIndex == 0
                                ? card![key][row]
                                : tableIndex == 1
                                    ? card1![key][row]
                                    : tableIndex == 2
                                        ? card2![key][row]
                                        : card3![key][row];
                            final bool isSelected = tableIndex == 0
                                ? (cardDetails?.contains(number) ?? false)
                                : tableIndex == 1
                                    ? (cardDetails1?.contains(number) ?? false)
                                    : tableIndex == 2
                                        ? (cardDetails2?.contains(number) ??
                                            false)
                                        : (cardDetails3?.contains(number) ??
                                            false);
                            return GestureDetector(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: isSelected
                                        ? Color.fromARGB(255, 0, 162, 255)
                                        : const Color.fromARGB(
                                            255, 203, 203, 203)),
                                child: Center(
                                  child: Text(
                                    number == 0 ? '⭐️' : number.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 25, // Adjust button font size
                                      fontWeight:
                                          FontWeight.bold, // Make the text bold
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  if (tableIndex == 0) {
                                    if (cardDetails == null) {
                                      cardDetails = [];
                                    }
                                    if (isSelected) {
                                      cardDetails!.remove(number);
                                    } else {
                                      cardDetails!.add(number);
                                    }
                                  } else {
                                    if (cardDetails1 == null) {
                                      cardDetails1 = [];
                                    }
                                    if (isSelected) {
                                      cardDetails1!.remove(number);
                                    } else {
                                      cardDetails1!.add(number);
                                    }
                                  }
                                });
                              },
                            );
                            //  ElevatedButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       if (tableIndex == 0) {
                            //         if (cardDetails == null) {
                            //           cardDetails = [];
                            //         }
                            //         if (isSelected) {
                            //           cardDetails!.remove(number);
                            //         } else {
                            //           cardDetails!.add(number);
                            //         }
                            //       } else {
                            //         if (cardDetails1 == null) {
                            //           cardDetails1 = [];
                            //         }
                            //         if (isSelected) {
                            //           cardDetails1!.remove(number);
                            //         } else {
                            //           cardDetails1!.add(number);
                            //         }
                            //       }
                            //     });
                            //   },
                            //   style: ButtonStyle(
                            //     backgroundColor: MaterialStateProperty.all<Color>(
                            //       isSelected ? Colors.green : Colors.grey,
                            //     ),
                            //   ),
                            //   child: Text(
                            //     number.toString(),
                            //     style: TextStyle(
                            //       color: isSelected ? Colors.white : Colors.black,
                            //       fontSize: 17, // Adjust button font size
                            //       fontWeight: FontWeight.bold, // Make the text bold
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Selected Number:'),
                              Text(
                                x.text,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                cardName = null;

                                if (tableIndex == 0) {
                                  card = null;
                                  cardDetails = null;
                                } else {
                                  card1 = null;

                                  cardDetails1 = null;
                                }
                                _isTablePressed[tableIndex] = false;
                              });
                            },
                            child: const Text('Back'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // Clear the selected numbers and related variables
                                if (tableIndex == 0) {
                                  cardDetails = null;
                                } else if (tableIndex == 1) {
                                  cardDetails1 = null;
                                } else if (tableIndex == 2) {
                                  cardDetails2 = null;
                                } else if (tableIndex == 3) {
                                  cardDetails3 = null;
                                }
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Column(
                      children: [
                        Image.asset(
                          'assets/images/bb.png',
                          height: 70,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter a Number',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: x,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color.fromARGB(255, 0, 0, 0)),
                          decoration: InputDecoration(
                            labelStyle:
                                TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                            alignLabelWithHint:
                                true, // Aligns label with the hint text
                            floatingLabelBehavior: FloatingLabelBehavior
                                .auto, // Center aligns label
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    GestureDetector(
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2), // Shadow color
                                blurRadius: 6, // Spread radius
                                offset: Offset(
                                    0, 3), // Offset in x and y directions
                              ),
                            ],
                            borderRadius: BorderRadius.circular(17),
                            color: Color.fromARGB(255, 255, 98, 0)),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Play',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )),
                      ),
                      onTap: () {
                        setState(() {
                          _isTablePressed[tableIndex] = true;
                        });
                        checkNumber();
                      },
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       _isTablePressed[tableIndex] = true;
                    //     });
                    //     checkNumber();
                    //   },
                    //   child: const Text('Play'),
                    // ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumber(int tableIndex, TextEditingController x) {
    void checkNumber() {
      final int insertedNumber = int.tryParse(x.text) ?? 0;
      for (final currentCard in cards) {
        final cardNumber = currentCard['cardname'];
        if (cardNumber == insertedNumber) {
          setState(() {
            cardName = cardNumber.toString();
            if (tableIndex == 1) {
              card1 = currentCard;
              cardDetails1 = null;
            } else if (tableIndex == 2) {
              card2 = currentCard;
              cardDetails2 = null;
            } else if (tableIndex == 3) {
              card3 = currentCard;
              cardDetails3 = null;
            } else {
              card = currentCard;
              cardDetails = null;
            }
          });
          return;
        }
      }
      setState(() {
        cardName = null;
        card = null;
        card1 = null;
        card2 = null;
        card3 = null;
        cardDetails = null;
        cardDetails1 = null;
        cardDetails2 = null;
        cardDetails3 = null;
      });
    }

    double buttonSize = MediaQuery.of(context).size.shortestSide * 0.1;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isTablePressed[tableIndex] &&
                  ((tableIndex == 0 && card != null) ||
                      (tableIndex == 1 && card1 != null) ||
                      (tableIndex == 2 && card2 != null) ||
                      (tableIndex == 3 && card3 != null))) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLabel('B'),
                    _buildLabel('I'),
                    _buildLabel('N'),
                    _buildLabel('G'),
                    _buildLabel('O'),
                  ],
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        mainAxisSpacing: 10.0,
                        crossAxisSpacing: 10.0,
                        childAspectRatio: 1,
                      ),
                      itemCount: 25,
                      itemBuilder: (context, index) {
                        final row = index ~/ 5;
                        final col = index % 5;
                        final key = ['b', 'i', 'n', 'g', 'o'][col];
                        final number = tableIndex == 0
                            ? card![key][row]
                            : tableIndex == 1
                                ? card1![key][row]
                                : tableIndex == 2
                                    ? card2![key][row]
                                    : card3![key][row];
                        final bool isSelected = tableIndex == 0
                            ? (cardDetails?.contains(number) ?? false)
                            : tableIndex == 1
                                ? (cardDetails1?.contains(number) ?? false)
                                : tableIndex == 2
                                    ? (cardDetails2?.contains(number) ?? false)
                                    : (cardDetails3?.contains(number) ?? false);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (tableIndex == 0) {
                                if (cardDetails == null) {
                                  cardDetails = [];
                                }
                                if (isSelected) {
                                  cardDetails!.remove(number);
                                } else {
                                  cardDetails!.add(number);
                                }
                              } else if (tableIndex == 1) {
                                if (cardDetails1 == null) {
                                  cardDetails1 = [];
                                }
                                if (isSelected) {
                                  cardDetails1!.remove(number);
                                } else {
                                  cardDetails1!.add(number);
                                }
                              } else if (tableIndex == 2) {
                                if (cardDetails2 == null) {
                                  cardDetails2 = [];
                                }
                                if (isSelected) {
                                  cardDetails2!.remove(number);
                                } else {
                                  cardDetails2!.add(number);
                                }
                              } else if (tableIndex == 3) {
                                if (cardDetails3 == null) {
                                  cardDetails3 = [];
                                }
                                if (isSelected) {
                                  cardDetails3!.remove(number);
                                } else {
                                  cardDetails3!.add(number);
                                }
                              }
                            });
                          },
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color.fromARGB(255, 0, 162, 255)
                                  : const Color.fromARGB(255, 203, 203, 203),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              number == 0 ? '⭐️' : number.toString(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontSize: buttonSize * 0.4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       card1 = null;
                    //       cardDetails1 = null;
                    //       card2 = null;
                    //       cardDetails2 = null;
                    //       card3 = null;
                    //       cardDetails3 = null;
                    //       cardName = null;
                    //       card = null;
                    //       cardDetails = null;
                    //       _isTablePressed[tableIndex] = false;
                    //     });
                    //   },
                    //   child: const Text('Clear'),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       card1 = null;
                    //       cardDetails1 = null;
                    //       card2 = null;
                    //       cardDetails2 = null;
                    //       card3 = null;
                    //       cardDetails3 = null;
                    //       cardName = null;
                    //       card = null;
                    //       cardDetails = null;
                    //       _isTablePressed[tableIndex] = false;
                    //     });
                    //   },
                    //   child: const Text('Back'),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(' Number: ${x.text}'),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              cardName = null;

                              if (tableIndex == 0) {
                                card = null;
                                cardDetails = null;
                              } else if (tableIndex == 1) {
                                card1 = null;

                                cardDetails1 = null;
                              } else if (tableIndex == 2) {
                                card2 = null;

                                cardDetails2 = null;
                              } else if (tableIndex == 3) {
                                card3 = null;

                                cardDetails3 = null;
                              }
                              _isTablePressed[tableIndex] = false;
                            });
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      // Clear the selected numbers and related variables
                      if (tableIndex == 0) {
                        cardDetails = null;
                      } else if (tableIndex == 1) {
                        cardDetails1 = null;
                      } else if (tableIndex == 2) {
                        cardDetails2 = null;
                      } else if (tableIndex == 3) {
                        cardDetails3 = null;
                      }
                    });
                  },
                  child: const Text('Clear'),
                ),
              ] else ...[
                TextField(
                  controller: x,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: const Color.fromARGB(255, 4, 4, 4)),
                  decoration: const InputDecoration(
                    labelText: 'Enter a number',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.2), // Shadow color
                            blurRadius: 6, // Spread radius
                            offset:
                                Offset(0, 3), // Offset in x and y directions
                          ),
                        ],
                        borderRadius: BorderRadius.circular(17),
                        color: Color.fromARGB(255, 255, 98, 0)),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Play',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )),
                  ),
                  onTap: () {
                    setState(() {
                      _isTablePressed[tableIndex] = true;
                    });
                    checkNumber();
                  },
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     setState(() {
                //       _isTablePressed[tableIndex] = true;
                //     });
                //     checkNumber();
                //   },
                //   child: const Text('Play'),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}
