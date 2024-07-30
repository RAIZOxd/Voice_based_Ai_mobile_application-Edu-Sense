import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'common_methods.dart';
import 'synonyms.dart'; // Import the synonyms.dart file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SynonymsGame(),
    );
  }
}

class SynonymsGame extends StatefulWidget {
  @override
  _SynonymsGameState createState() => _SynonymsGameState();
}

class _SynonymsGameState extends State<SynonymsGame> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speech = stt.SpeechToText();
  bool isListening = false;
  String word = "happy";
  String? spokenWord;
  String? message;
  Timer? feedbackDebounce;
  Timer? tripleTapTimer;
  int tapCount = 0;
  final Random random = Random();

  int correctAnswers = 0;
  int totalAnswers = 0;

  @override
  void initState() {
    super.initState();
    _speak("Welcome to the Synonyms Game! Double tap to hear the word. Swipe left to speak a synonym.");
    _nextWord();
  }

  _speak(String text) async {
    await flutterTts.speak(text);
  }

  _listen() async {
    bool available = await speech.initialize(
      onStatus: (val) => print('onStatus: $val'),
    );
    if (available) {
      setState(() => isListening = true);
      speech.listen(
        onResult: (val) => setState(() {
          spokenWord = val.recognizedWords;
          isListening = false;
          _validateAnswer();
        }),
      );
    }
  }

  _validateAnswer() {
    if (spokenWord != null && wordSynonyms[word]!.contains(spokenWord)) {
      setState(() {
        message = "Correct!";
        correctAnswers++;
        totalAnswers++;
      });
      _giveFeedback("Correct! Great job!");
      _nextWord();
    } else {
      setState(() {
        message = "Try again!";
        totalAnswers++;
      });
      _giveFeedback("You are incorrect. Try again!");
    }
    speech.stop(); // Stop listening after validating
  }

  _giveFeedback(String feedback) {
    feedbackDebounce?.cancel();
    feedbackDebounce = Timer(const Duration(milliseconds: 600), () {
      speech.stop(); // Ensure that the app is not listening when it speaks
      _speak(feedback);
    });
  }

  _nextWord() {
    final keys = wordSynonyms.keys.toList();
    word = keys[random.nextInt(keys.length)];
  }

  _handleTap() {
    tapCount++;
    tripleTapTimer?.cancel();
    tripleTapTimer = Timer(const Duration(milliseconds: 500), () {
      if (tapCount == 3) {
        _nextWord();
        _speak(word); // Play the next word
      }
      tapCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Synonyms Game'),
        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: _handleTap,
        onDoubleTap: () {
          _speak(word);
        },
        onPanUpdate: (details) {
          // Swiping in right direction.
          if (details.delta.dx > 0 && details.delta.dy == 0) {
            debugPrint("swiping left to right");
            speak('Now you are in Home screen');
            Navigator.of(context).popUntil((route) => route.isFirst);
          }

          // swipe left to answer
          if (details.delta.dx < 0 && details.delta.dy == 0) {
            _listen();
          }
        },
        // onHorizontalDragEnd: (details) {
        //   if (details.primaryVelocity!.compareTo(0) == -1) {
        //     _listen();
        //   } else if (details.primaryVelocity!.compareTo(0) == 1) {
        //     _speak(word);
        //   }
        // },
        child: Container(
          color: Colors.lightBlue[100],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/book.png', // Replace with your image
                  width: 500,
                  height: 180,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => _speak(word),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 39, 20, 204)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      "Play Word",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _listen,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 39, 20, 204)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      "Speak Synonym",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      _nextWord();
                      _speak(word); // Play the next word
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 39, 20, 204)),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                    child: const Text(
                      "Next Word",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "You Answer: ${spokenWord ?? ''}",
                  style: const TextStyle(fontSize: 35),
                ),
                Text(
                  message ?? '',
                  style: const TextStyle(fontSize: 35),
                ),
                Text(
                  "Correct Answers: $correctAnswers ",
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
