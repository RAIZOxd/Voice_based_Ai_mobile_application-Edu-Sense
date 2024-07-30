import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'common_methods.dart';
import 'fun_spelling_screen.dart';
import 'similar_words_screen.dart';
import 'sounds_of_animals_screen.dart';

class GamingModule extends StatefulWidget {
  const GamingModule({super.key});

  @override
  State<GamingModule> createState() => _GamingModuleState();
}

class _GamingModuleState extends State<GamingModule> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      speak('''Welcome to the Gaming Module.
      To play the Sound of animal game, tap the top of the screen. To play the fun spelling game, tap the middle of the screen. To play the Synonyms Word game  tap the bottom of the screen.
      ''');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          debugPrint("swiping left to right");
          stopSpeak();
          Get.back();
          speak('Now you are in Home screen');
        }

        // Swiping in left direction.
        if (details.delta.dx < 0) {
          debugPrint("swiping right to left");
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gaming Module'),
          // backgroundColor: const Color.fromARGB(255, 39, 20, 204),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                text: 'Sounds of Animals',
                imagePath: 'assets/images/a.png',
                imageHeight: h * 0.16,
                imageWidth: h * 0.16,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen()),
                  );
                },
              ),
              CustomButton(
                text: 'Fun Spelling',
                imagePath: 'assets/images/b.png',
                imageHeight: h * 0.16,
                imageWidth: h * 0.16,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SpellingGame()),
                  );
                },
              ),
              CustomButton(
                text: 'Synonyms Words',
                imagePath: 'assets/images/c.png',
                imageHeight: h * 0.16,
                imageWidth: h * 0.16,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SynonymsGame()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
