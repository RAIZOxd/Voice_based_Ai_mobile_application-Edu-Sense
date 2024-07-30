import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PronunciationGame(),
    );
  }
}

class PronunciationGame extends StatefulWidget {
  @override
  _PronunciationGameState createState() => _PronunciationGameState();
}

class _PronunciationGameState extends State<PronunciationGame> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  String currentWord = "sky";
  String? userPronunciation;
  String? message;
  List<String> easyWords = ["sky", "cat", "dog", "hat"];
  List<String> mediumWords = ["banana", "guitar", "table", "orange"];
  List<String> hardWords = ["elephant", "chocolate", "technology", "paradise"];
  String? selectedLevel = 'easy'; // Default level

  int correctCount = 0;
  int incorrectCount = 0;

  bool shouldValidatePronunciation = false; // Flag to control validation

  @override
  void initState() {
    super.initState();
    _pronounceWord();
    _speak(
        "Welcome to the Pronunciation Game! Please pronounce the word that you hear. Double tap to hear the word.");
    _listenForVoiceCommands(); // Start listening for voice commands
  }

  _speak(String text) async {
    await flutterTts.speak(text);
  }

  _listenForPronunciation() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
    );
    if (available) {
      speech.listen(
        onResult: (val) => setState(() {
          userPronunciation = val.recognizedWords;
        }),
        onSoundLevelChange: (val) {
          if (val > 500 && shouldValidatePronunciation) {
            _validatePronunciation();
          }
        },
        cancelOnError: true,
      );
    }
  }

  _validatePronunciation() {
    shouldValidatePronunciation = false; // Reset the flag
    String pronouncedWord = userPronunciation?.toLowerCase() ?? "";
    String currentWordLower = currentWord.toLowerCase();

    if (pronouncedWord == currentWordLower) {
      setState(() {
        message = "Correct! You pronounced it correctly.";
        correctCount++;
      });
      _speak("Correct! You pronounced it correctly.");
    } else {
      setState(() {
        message = "Try again! Your pronunciation is incorrect.";
        incorrectCount++;
      });
      _speak("Try again! Your pronunciation is incorrect.");
    }
  }

  _pronounceWord() {
    setState(() {
      userPronunciation = null;
      message = null;
      shouldValidatePronunciation = true; // Set the flag for validation
    });

    List<String> selectedWordList = easyWords;

    if (selectedLevel == 'medium') {
      selectedWordList = mediumWords;
    } else if (selectedLevel == 'hard') {
      selectedWordList = hardWords;
    }

    final random = Random();
    currentWord = selectedWordList[random.nextInt(selectedWordList.length)];

    _speak("Pronounce the word:");
    _speak(currentWord);
  }

  _listenForVoiceCommands() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
    );

    if (available) {
      speech.listen(
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
    _pronounceWord();
    _speak("Level changed to $level");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pronunciation Game'),
        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
      ),
      body: GestureDetector(
        onTap: _pronounceWord,
        onDoubleTap: () {
          print('Double Tapped!');
          _pronounceWord();
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity!.compareTo(0) == -1) {
            _listenForPronunciation();
          } else if (details.primaryVelocity!.compareTo(0) == 1) {
            _pronounceWord();
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
                  'assets/images/bee.png', // Replace with your image
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
                      child: Text("Easy"),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 39, 20, 204), // Custom color
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _changeDifficultyLevel('medium');
                      },
                      child: Text("Medium"),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 39, 20, 204), // Custom color
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        _changeDifficultyLevel('hard');
                      },
                      child: Text("Hard"),
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(
                            255, 39, 20, 204), // Custom color
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _pronounceWord,
                    child: const Text(
                      "Pronounce Word",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 39, 20, 204), // Custom color
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _listenForPronunciation,
                    child: const Text(
                      "Listen for Pronunciation",
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 39, 20, 204), // Custom color
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Your Pronunciation: ${userPronunciation ?? ''}",
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
        child: Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Correct: $correctCount'),
              SizedBox(width: 20),
              Text('Incorrect: $incorrectCount'),
            ],
          ),
        ),
      ),
    );
  }
}
