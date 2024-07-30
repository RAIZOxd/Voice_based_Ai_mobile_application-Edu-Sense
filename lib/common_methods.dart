import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterTts flutterTts = FlutterTts();

Future<void> speak(String text) async {
  await flutterTts.setLanguage('en-US'); // Set the language
  await flutterTts.setSpeechRate(0.5); // Adjust the speech rate
  await flutterTts.speak(text);
}

Future<void> stopSpeak() async {
  await flutterTts.stop();
}

Future<PermissionStatus> requestMicrophonePermissions() async {
  var status = await Permission.microphone.status;
  if (!status.isGranted) {
    await Permission.microphone.request();
  }

  return status;
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String imagePath;
  final double imageHeight;
  final double imageWidth;

  const CustomButton({super.key,
    required this.text,
    required this.onPressed,
    required this.imagePath,
    this.imageHeight = 80.0, // Default image height
    this.imageWidth = 80.0, // Default image width
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.017),
        // minimumSize: const Size(360, 200), // Adjust the width and height
        fixedSize: Size.fromWidth(MediaQuery.of(context).size.width),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Adjust the radius
        ),
        backgroundColor: const Color.fromARGB(255, 13, 128, 222), // Set the button color here
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: imageHeight,
            width: imageWidth,
          ),
          const SizedBox(height: 8.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 35, // Adjust the font size
              color: Colors.white, // Set the text color
            ),
          ),
        ],
      ),
    );
  }
}
