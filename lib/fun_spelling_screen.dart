import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'common_methods.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SpellingGame(),
    );
  }
}

class SpellingGame extends StatefulWidget {
  @override
  _SpellingGameState createState() => _SpellingGameState();
}

class _SpellingGameState extends State<SpellingGame> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  String currentWord = "sky";
  String? userSpelling;
  String? message;
  List<String> easyWords = ["sky", "cat", "dog", "hat"];
  List<String> mediumWords = ["banana", "guitar", "table", "orange"];
  List<String> hardWords = ["elephant", "chocolate", "technology", "paradise"];
  String? selectedLevel = 'easy'; // Default level

  int correctCount = 0;
  int incorrectCount = 0;

  bool shouldValidateSpelling = false; // Flag to control validation
  List<String> spelledLetters = []; // List to hold the spelled letters

  @override
  void initState() {
    super.initState();
    _playWord();
    _speak(
        "Welcome to the Spelling Game! Please spell the word that you hear. Double tap to hear the word. Tap to speak the word you heard.");
    _listenForVoiceCommands(); // Start listening for voice commands
  }

  _speak(String text) async {
    await flutterTts.speak(text);
  }

  _listenForSpelling() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
    );
    if (available) {
      speech.listen(
        pauseFor: const Duration(milliseconds: 2500),
        onResult: (val) => setState(() {
          userSpelling = val.recognizedWords;
          spelledLetters = userSpelling?.split('') ?? [];
          _validateSpelling(); // Automatically validate spelling
        }),
      );
    }
  }

  _validateSpelling() {
    if (userSpelling == null || userSpelling!.isEmpty) return; // Avoid double checking

    shouldValidateSpelling = false; // Reset the flag
    String spelledWord = spelledLetters.join('').toLowerCase();
    if (spelledWord == currentWord || spelledLetters.join('') == currentWord) {
      setState(() {
        message = "Correct! You spelled it correctly.";
        correctCount++;
      });
      _speak("Correct! You spelled it correctly.");
    } else {
      setState(() {
        message = "Try again! Your spelling is incorrect.";
        incorrectCount++;
      });
      _speak("Try again! Your spelling is incorrect.");
    }
    // Clear the user spelling after validation
    userSpelling = null;
    spelledLetters = [];
  }

  Future<void> _playWord() async {
    setState(() {
      userSpelling = null;
      message = null;
      shouldValidateSpelling = true; // Set the flag for validation
      spelledLetters = []; // Clear the spelled letters
    });

    List<String> selectedWordList = easyWords;

    if (selectedLevel == 'medium') {
      selectedWordList = mediumWords;
    } else if (selectedLevel == 'hard') {
      selectedWordList = hardWords;
    }

    final random = Random();
    currentWord = selectedWordList[random.nextInt(selectedWordList.length)];

    _speak("Spell the word:");
    _speak(currentWord);
  }

  _listenForVoiceCommands() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
    );

    if (available) {
      speech.listen(
        pauseFor: const Duration(milliseconds: 2500),
        onResult: (val) {
          String command = val.recognizedWords.toLowerCase();
          if (command.contains("easy")) {
            _changeDifficultyLevel('easy');
          } else if (command.contains("medium")) {
            _changeDifficultyLevel('medium');
          } else if (command.contains("hard")) {
            _changeDifficultyLevel('hard');
          }
        },
      );
    }
  }

  void _changeDifficultyLevel(String level) {
    setState(() {
      selectedLevel = level;
    });
    _playWord();
    _speak("Level changed to $level");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spelling Game'),
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
      ),
      body: GestureDetector(
        onTap: () => _listenForSpelling(),
        onDoubleTap: () {
          _playWord();
        },
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 0 && details.delta.dy == 0) {
            debugPrint("swiping left to right");
            speak('Now you are in Home screen');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
        child: Container(
          color: Colors.lightBlue[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/bee.png', // image
                  width: 500,
                  height: 250,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _changeDifficultyLevel('easy');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 39, 20, 204), // Custom color
                      ),
                      child: const Text("Easy"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _changeDifficultyLevel('medium');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 39, 20, 204), // Custom color
                      ),
                      child: const Text("Medium"),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _changeDifficultyLevel('hard');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 39, 20, 204), // Custom color
                      ),
                      child: const Text("Hard"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _playWord,
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromARGB(255, 39, 20, 204), // Custom color
                    ),
                    child: const Text(
                      "Play Word",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
//                const SizedBox(height: 20),
//                SizedBox(
//                  width: 200,
//                  height: 60,
//                  child: ElevatedButton(
//                    onPressed: _listenForSpelling,
//                    style: ElevatedButton.styleFrom(
//                      primary: const Color.fromARGB(255, 39, 20, 204), // Custom color
//                    ),
//                    child: const Text(
//                      "Speak Spelling",
//                      style: TextStyle(fontSize: 20),
//                    ),
//                  ),
//                ),
                const SizedBox(height: 20),
                Text(
                  "Your Spelling: ${spelledLetters.join('')}",
                  style: const TextStyle(fontSize: 25),
                ),
                Text(
                  message ?? '',
                  style: const TextStyle(fontSize: 25),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Correct: $correctCount'),
              const SizedBox(width: 20),
              Text('Incorrect: $incorrectCount'),
            ],
          ),
        ),
      ),
    );
  }
}
