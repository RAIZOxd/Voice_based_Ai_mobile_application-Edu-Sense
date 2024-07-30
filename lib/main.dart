import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';

import 'common_methods.dart';
import 'gaming_module.dart';
import 'online_examination_module.dart';
import 'supportive_chatbot.dart';
import 'voice_based_calculator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureGemini();

  runApp(const MyApp());
}

configureOpenAI() {
  OpenAI.apiKey = ;
  OpenAI.requestsTimeOut = const Duration(seconds: 60);
  OpenAI.showLogs = true;
  OpenAI.showResponsesLogs = true;
}

configureGemini() {
  Gemini.init(apiKey: );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const Dashboard(),
      theme: ThemeData(
        fontFamily: 'Lexend',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      speakInstructions();
    });

    super.initState();
  }

  void speakInstructions() {
    speak('''Welcome to the Edu Sense E learning Platform.
    
    Tap top left corner to use Voice Bot.
    
    Tap top right corner to use Online examination.
    
    Tap bottom left corner to use Gaming module.
    
    Tap bottom right corner to use Voice based calculator.
    
    To repeat instructions, Double tab middle of the screen.
    ''');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onDoubleTap: () => speakInstructions(),
              child: Container(
                width: w,
                height: h * 0.175,
                color: Colors.white,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Edu Sense",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Double tab to repeat instructions",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 0.5 * w,
              height: 0.4 * h,
              child: GestureDetector(
                onTap: () {
                  stopSpeak();
                  Get.to(() => const SupportiveChatBot());
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Supportive\nVoicebot',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        'assets/images/logo_voice_bot.png',
                        width: 0.3 * w,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              width: 0.5 * w,
              height: 0.4 * h,
              child: GestureDetector(
                onTap: () {
                  stopSpeak();
                  Get.to(() => const OnlineExaminationModule());
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Online\nExamination',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        'assets/images/logo_tutor.png',
                        width: 0.3 * w,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 0.5 * w,
              height: 0.4 * h,
              child: GestureDetector(
                onTap: () {
                  stopSpeak();
                  Get.to(() => const GamingModule());
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Gaming\nModule',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        'assets/images/logo_gaming.png',
                        width: 0.45 * w,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
              width: 0.5 * w,
              height: 0.4 * h,
              child: GestureDetector(
                onTap: () {
                  stopSpeak();
                  Get.to(() => const VoiceBasedCalculator());
                },
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Voice based\nCalculator',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Image.asset(
                        'assets/images/logo_calculator.jpeg',
                        width: 0.3 * w,
                        fit: BoxFit.fitWidth,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
