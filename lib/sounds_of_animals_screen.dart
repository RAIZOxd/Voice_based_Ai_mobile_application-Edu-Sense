import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  TextEditingController guessController = TextEditingController();
  stt.SpeechToText _speechToText = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  List<String> animalSounds = [
    'lion.mp3',
    'cat.mp3',
    'dog.mp3',
    'cow.mp3',
    'frog.mp3',
    'peacock.mp3',
    'horse.mp3',
    'elephant.mp3',
    'duck.mp3'
        'bird.mp3'
        'owl.mp3'
        'elk.mp3'
        'Sheep.mp3'
        'Chicken.mp3'
  ]; // sound files
  List<String> animalNames = [
    'lion',
    'cat',
    'dog',
    'cow',
    'frog',
    'peacock',
    'horse',
    'elephant',
    'duck'
        'bird'
        'owl'
        'elk'
        'sheep'
        'chicken'
  ]; // animal names
  int currentAnimalIndex = 0;

  @override
  void initState() {
    super.initState();
    playSound();
    speak(
        'Welcome to the Animal Sound Game. Listen to the animal sound and guess the animal. Double tap to hear the Animal sound. Tap to Answer.');
  }

  void playSound() async {
    await _audioPlayer.play(AssetSource('audio/${animalSounds[currentAnimalIndex]}'));
  }

  void checkGuess() {
    String userGuess = guessController.text.toLowerCase();
    String correctAnimal = animalNames[currentAnimalIndex];
    if (userGuess == correctAnimal) {
      speak('Correct! Your guess is right. Tap middle to next animal.');
      showDialog(
          context: context,
          builder: (_) {
            final w = MediaQuery.of(context).size.width;
            final h = MediaQuery.of(context).size.height;
            return AlertDialog(
              title: const Text('Correct!'),
              content: const Text('Your guess is correct.'),
              actionsAlignment: MainAxisAlignment.center,
              // contentPadding: EdgeInsets.symmetric(vertical: h * 0.15),
              // alignment: Alignment.center,
              actions: [
                SizedBox(
                  width: w * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      moveToNextAnimal();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
                        surfaceTintColor: const Color.fromARGB(255, 39, 20, 204),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.symmetric(vertical: h * 0.1)
                    ),
                    child: const Text('Next Animal'),
                  ),
                ),
              ],
            );
          }
      );
    } else {
      speak('Incorrect. Your guess is incorrect. Try again.');
      showDialog(
        context: context,
        builder: (_) =>
            AlertDialog(
              title: const Text('Incorrect'),
              content: const Text('Your guess is incorrect. Try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void moveToNextAnimal() {
    if (currentAnimalIndex < animalSounds.length - 1) {
      setState(() {
        currentAnimalIndex++;
      });
      playSound();
      speak('Listen to the next animal sound and make your guess.');
    } else {
      speak('Congratulations! You have finished the game.');
    }
  }

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  void startListening() async {
    if (await _speechToText.initialize()) {
      _speechToText.listen(
        pauseFor: const Duration(milliseconds: 2500),
        onResult: (result) {
          if (result.finalResult) {
            guessController.text = result.recognizedWords.toLowerCase();
            _speechToText.stop();
            if (mounted) {
              setState(() {});
            }
            checkGuess();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Sound Game'),
        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTap: playSound,
            onTap: () => startListening(),
            onPanUpdate: (details) {
              // Swiping in right direction.
              if (details.delta.dx > 0 && details.delta.dy == 0) {
                debugPrint("swiping left to right");
                speak('Now you are in Home screen');
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            // onHorizontalDragEnd: (details) {
            //   if (details.primaryVelocity! < 0) {
            //     startListening();
            //   }
            // },
            child: Container(
              color: Colors.lightBlue[100],
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onDoubleTap: playSound,
                  onTap: () => startListening(),
                  onPanUpdate: (details) {
                    // Swiping in right direction.
                    if (details.delta.dx > 0 && details.delta.dy == 0) {
                      debugPrint("swiping left to right");
                      speak('Now you are in Home screen');
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: Image.asset(
                    'assets/images/animals.png', // image file name
                    width: 300,
                    height: 300,
                  ),
                ),
                ElevatedButton(
                  onPressed: playSound,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 39, 20, 204),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Play Sound'),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: guessController,
                    decoration: const InputDecoration(
                      labelText: 'Your Answer',
                    ),
                    maxLines: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: checkGuess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Check'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: startListening,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 39, 20, 204),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Voice Input'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
