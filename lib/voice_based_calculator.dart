import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'common_methods.dart';

class VoiceBasedCalculator extends StatefulWidget {
  const VoiceBasedCalculator({super.key});

  @override
  State<VoiceBasedCalculator> createState() => _VoiceBasedCalculatorState();
}

class _VoiceBasedCalculatorState extends State<VoiceBasedCalculator> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _flutterTts.speak('''Welcome to the Voice Based Calculator.
      Swipe left to give number input.
      Swipe right to go to home.      
      Tap top left corner to add.
      Tap top right corner to subtract.
      Tap bottom left corner to multiply.
      Tap bottom right corner to divide.
      Tap bottom, to Go to Calculator.
      ''');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          debugPrint("swiping left to right");
          _flutterTts.stop();
          Get.back();
          speak('Now you are in Home screen');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            const Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome to the',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Voice based\n Calculator",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      '''▪️Swipe left to give number input\n▪️Swipe right to go to home\n\n▪️Tap top left corner to ADD\n▪️Tap top right corner to SUBTRACT\n▪️Tap bottom left corner to MULTIPLY\n▪️Tap bottom right corner to DIVIDE\n\n▪️Tap bottom, to Go to Calculator''',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        height: 1.2,
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.94,
                height: MediaQuery.of(context).size.height * 0.2,
                margin: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const CalculationPage());
                    _flutterTts.speak("Now you are in Calculator");
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B93DF),
                      surfaceTintColor: const Color(0xFF0B93DF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                  child: const Text('Get Started'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CalculationPage extends StatefulWidget {
  const CalculationPage({super.key});

  @override
  State<CalculationPage> createState() => _CalculationPageState();
}

class _CalculationPageState extends State<CalculationPage> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  int? numberInput;
  bool isFreshStart = true;

  String selectedOperator = '';
  StringBuffer operationSequence = StringBuffer("");
  double answer = 0;
  bool showAnswer = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeSpeechToText();
      _flutterTts.speak('Tap middle and say number first');
    });
    super.initState();
  }

  void initializeSpeechToText() {
    _speechToText.initialize();
    setState(() {});
  }

  void assignRecognizedNumberToSequence(String word) {
    if (word.isEmpty) {
      _flutterTts.speak('Tap middle and say number again');
    } else if (digitMap.containsKey(word)) {
      if (mounted) {
        setState(() {
          int value = digitMap[word]!;
          if (numberInput == null && isFreshStart) {
            answer = value.toDouble();
            isFreshStart = false;
          }
          numberInput = value;
          operationSequence.write(" $value");
          updateCalculation();
        });
      }
    } else {
      int? newNumber = int.tryParse(word);
      if (newNumber == null) {
        _flutterTts.speak('Tap middle and say number again');
      } else {
        if (mounted) {
          setState(() {
            if (numberInput == null && isFreshStart) {
              answer = newNumber.toDouble();
              isFreshStart = false;
            }
            numberInput = newNumber;
            operationSequence.write(" $newNumber");
            updateCalculation();
          });
        }
      }
    }
  }

  void updateCalculation() {
    if (selectedOperator.isNotEmpty && numberInput != null) {
      if (mounted) {
        setState(() {
          switch (selectedOperator) {
            case '+':
              answer += numberInput!;
              selectedOperator = '';
              break;
            case '-':
              answer -= numberInput!;
              selectedOperator = '';
              break;
            case '*':
              answer *= numberInput!;
              selectedOperator = '';
              break;
            case '/':
              answer /= numberInput!;
              selectedOperator = '';
              break;
            default:
              return;
          }
        });
      }
    }
  }

  void startListening() async {
    _speechToText.listen(
      pauseFor: const Duration(milliseconds: 2500),
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty && result.finalResult) {
          String detectedNewWord = '';
          if (result.recognizedWords.contains(' ')) {
            detectedNewWord = result.recognizedWords.split(' ').first.toLowerCase();
            // _speechToText.cancel();
            // assignRecognizedNumberToSequence(recognizedWord);
          } else {
            detectedNewWord = result.recognizedWords.toLowerCase();
            // _speechToText.cancel();
            // assignRecognizedNumberToSequence(recognizedWord);
          }

          print("detecting numbers: $detectedNewWord");

          if (mounted) {
            _speechToText.cancel();
            setState(() {});
          }

          if (detectedNewWord.isNotEmpty) {
            assignRecognizedNumberToSequence(detectedNewWord);
          }
        }
      },
    );
  }

  void selectOperator(String operator) {
    if (numberInput == null) {
      _flutterTts.speak('Tap middle and say number.');
    } else {
      // number input has value
      if (mounted) {
        setState(() {
          selectedOperator = operator;
          operationSequence.write(" $operator");
          numberInput = null;
          // speak('Tap middle and say next number');
          switch (selectedOperator) {
            case '+':
              _flutterTts.speak('plus');
              break;
            case '-':
              _flutterTts.speak('minus');
              break;
            case '*':
              _flutterTts.speak('multiply');
              break;
            case '/':
              _flutterTts.speak('divide');
              break;
            default:
              return;
          }
        });
      }
    }
  }

  void showFinalAnswer() {
    if (mounted) {
      setState(() {
        showAnswer = true;
        selectedOperator = '';
        numberInput = null;
        operationSequence.clear();
      });
    }
    _flutterTts.speak('Answer is ${answer.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        // reset to initial state
        if (mounted && showAnswer == true) {
          setState(() {
            showAnswer = false;
            answer = 0;
            isFreshStart = true;
          });
        }

        if (numberInput == null) {
          startListening();
        } else {
          _flutterTts.speak('Select operator');
        }
      },
      onDoubleTap: () {
        if (operationSequence.isNotEmpty) {
          showFinalAnswer();
        }
      },
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          debugPrint("swiping left to right");
          _flutterTts.stop();
          Navigator.of(context).popUntil((route) => route.isFirst);
          speak('Now you are in Home screen');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Calculation',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      width: w,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.09),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        operationSequence.toString(),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          letterSpacing: -0.03,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    showAnswer
                        ? Text(
                            "Answer is\n${answer.toStringAsFixed(2)}",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0C20D4),
                            ),
                          )
                        : SizedBox(
                            width: w,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Latest number input',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.09),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${numberInput ?? '    '}',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          letterSpacing: -0.03,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  answer.toStringAsFixed(2),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Selected operator',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.09),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        selectedOperator.isNotEmpty ? selectedOperator : '    ',
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          letterSpacing: -0.03,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 0.48 * w,
                height: 0.36 * h,
                child: ElevatedButton(
                  onPressed: () => selectOperator('+'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA49FE5),
                    surfaceTintColor: const Color(0xFFA49FE5),
                    foregroundColor: Colors.black,
                    // elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '+',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.27,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: 0.48 * w,
                height: 0.36 * h,
                child: ElevatedButton(
                  onPressed: () => selectOperator('-'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCC946),
                    surfaceTintColor: const Color(0xFFFCC946),
                    foregroundColor: Colors.black,
                    // elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '-',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.27,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                width: 0.48 * w,
                height: 0.36 * h,
                child: ElevatedButton(
                  onPressed: () => selectOperator('*'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA8E59F),
                    surfaceTintColor: const Color(0xFFA8E59F),
                    foregroundColor: Colors.black,
                    // elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'x',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.27,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: 0.48 * w,
                height: 0.36 * h,
                child: ElevatedButton(
                  onPressed: () => selectOperator('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B93DF),
                    surfaceTintColor: const Color(0xFF0B93DF),
                    foregroundColor: Colors.black,
                    // elevation: 10,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    '÷',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: w * 0.27,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final digitMap = <String, int>{
  'one': 1,
  'on': 1,
  'two': 2,
  'to': 2,
  'tree': 3,
  'three': 3,
  'the': 3,
  'for': 4,
  'four': 4,
  'five': 5,
  'hi': 5,
  'fry': 5,
  'see': 6,
  'six': 6,
  'seven': 7,
  'hey': 8,
  'eight': 8,
  'he': 8,
  'nine': 9,
  'then': 10,
  'ten': 10,
};
