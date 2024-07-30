import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'common_methods.dart';

class ExamQuestions {
  final String question, correctAnswer, number;
  final List<String> possibleAnswers;

  ExamQuestions({
    required this.question,
    required this.correctAnswer,
    required this.number,
    this.possibleAnswers = const <String>[],
  });
}

class Level {
  String name;
  String tutor;
  String contact;

  Level({required this.name, required this.tutor, required this.contact});
}

final levelList = <Level>[
  Level(
    name: 'Beginner',
    tutor: 'Mrs. Dammika Ranepura',
    contact: 'dammika.r@gmail.com',
  ),
  Level(
    name: 'Intermediate',
    tutor: 'Mr. Haresh Bandara',
    contact: 'haresh.b@gmail.com',
  ),
  Level(
    name: 'Advanced',
    tutor: 'Mr. Ruwan Perera',
    contact: 'ruwan.p@gmail.com',
  ),
];

final questionsList = <ExamQuestions>[
  ExamQuestions(
    number: '01',
    question: 'What is the color of blood?',
    correctAnswer: 'red',
  ),
  ExamQuestions(
    number: '02',
    question: 'How many planets do the solar system have?',
    correctAnswer: 'eight',
    possibleAnswers: ['8'],
  ),
  ExamQuestions(
    number: '03',
    question: 'A bird can fly? Yes or No',
    correctAnswer: 'yes',
  ),
  ExamQuestions(
    number: '04',
    question: 'Which animal is known as the king of the forest?',
    correctAnswer: 'lion',
  ),
  ExamQuestions(
    number: '05',
    question: 'How many colors does a rainbow have?',
    correctAnswer: 'seven',
    possibleAnswers: ['7'],
  ),
  ExamQuestions(
    number: '06',
    question: 'Which number comes after Ten?',
    correctAnswer: '11',
    possibleAnswers: ['eleven'],
  ),
  ExamQuestions(
    number: '07',
    question: 'The name of our planet is?',
    correctAnswer: 'earth',
  ),
  ExamQuestions(
    number: '08',
    question: 'How many alphabets are there in English language?',
    correctAnswer: '26',
    possibleAnswers: ['twenty six'],
  ),
  ExamQuestions(
    number: '09',
    question: 'Which day comes after Friday?',
    correctAnswer: 'saturday',
  ),
  ExamQuestions(
    number: '10',
    question: 'whats the answer to 50 divided by 5?',
    correctAnswer: 'ten',
    possibleAnswers: ['10'],
  ),
];

class OnlineExaminationModule extends StatefulWidget {
  const OnlineExaminationModule({super.key});

  @override
  State<OnlineExaminationModule> createState() => _OnlineExaminationModuleState();
}

class _OnlineExaminationModuleState extends State<OnlineExaminationModule> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _flutterTts.speak(
          '''Welcome to the Online Examination.We will ask questions from you.Tap middle of screen, to answer.Tap bottom right corner, to continue to exam.''');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          print("swiping left to right");
          _flutterTts.stop();
          Get.back();
          speak('Now you are in Home screen');
        }

        // Swiping in left direction.
        if (details.delta.dx < 0) {
          print("swiping right to left");
        }
      },
      child: Scaffold(
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
                    "Online\nExamination",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.4,
                      fontSize: 22,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      '''Welcome to online examination!\nWe will ask questions from you.\nDouble tap middle of screen, to answer.''',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.2,
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                width: .6 * w,
                height: .16 * h,
                margin: const EdgeInsets.only(right: 5, bottom: 5),
                child: ElevatedButton(
                  onPressed: () {
                    _flutterTts.stop();
                    Get.to(() => const QuestionIteratorPage());
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B93DF),
                      surfaceTintColor: const Color(0xFF0B93DF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                  child: const Text('Get Started'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionIteratorPage extends StatefulWidget {
  const QuestionIteratorPage({super.key});

  @override
  State<QuestionIteratorPage> createState() => _QuestionIteratorPageState();
}

class _QuestionIteratorPageState extends State<QuestionIteratorPage> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  late ExamQuestions currentQuestion;

  String currentAnswer = '';
  int correctAnswerCount = 0;
  bool canJumpToNextQuestion = false;
  bool isIncorrect = false;

  void startListening() async {
    if (await _speechToText.initialize()) {
      _speechToText.listen(
        pauseFor: const Duration(milliseconds: 2500),
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            if (mounted) {
              setState(() {
                currentAnswer = result.recognizedWords.split(' ').first.toLowerCase();
              });
              _speechToText.stop();
              assignNumberValues(currentAnswer);
              Future.delayed(const Duration(milliseconds: 2600), () {
                _flutterTts.speak("Tap bottom to submit");
              });
            }
          }
        },
      );
    }
  }

  void assignNumberValues(String word) {
    if (word.isNotEmpty && digitMap.containsKey(word)) {
      if (mounted) {
        setState(() {
          final value = digitMap[word]!;
          currentAnswer = value.toString();
        });
      }
    }
  }

  void checkGuess() {
    if (currentAnswer.isEmpty) {
      _flutterTts.speak('No answer given. Tap middle to answer again');
    } else {
      if (currentAnswer.toLowerCase().contains(currentQuestion.correctAnswer.toLowerCase()) ||
          currentQuestion.possibleAnswers
              .any((element) => element.toLowerCase().contains(currentAnswer.toLowerCase()))) {
        _flutterTts.speak('Correct. Tap bottom to next question');
        if (mounted) {
          setState(() {
            correctAnswerCount++;
            canJumpToNextQuestion = true;
          });
        }
      } else {
        _flutterTts.speak('Incorrect. Correct answer is ${currentQuestion.correctAnswer}. Tap bottom to next question');
        if (mounted) {
          setState(() {
            canJumpToNextQuestion = true;
            isIncorrect = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    currentQuestion = questionsList.first;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeSpeechToText();
      _flutterTts.speak(currentQuestion.question);
    });
  }

  void initializeSpeechToText() {
    _speechToText.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanUpdate: (details) async {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          debugPrint("swiping left to right");
          Get.back();
          _flutterTts.speak('Now you are in Online Exam page. Swipe right to go home.');
        }

        // Swiping in left direction.
        if (details.delta.dx < 0 && details.delta.dy == 0) {
          debugPrint("swiping right to left");
        }
      },
      onTap: () async {
        // await _flutterTts.speak('Listening.');
        // await requestMicrophonePermissions();
        startListening();
      },
      onDoubleTap: () async {
        // Repeat question
        await _flutterTts.speak(currentQuestion.question);
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Question ${currentQuestion.number}',
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                    const Text(
                      'Tell your answer',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      width: 1 * w,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 1.4), borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        currentAnswer,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.18 * h),
                      child: isIncorrect
                          ? Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 0.09 * w, vertical: 0.02 * h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBFBFBF).withOpacity(.37),
                                  borderRadius: BorderRadius.circular(23),
                                ),
                                child: Column(
                                  children: [
                                    const Text(
                                      'Your answer is',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      'INCORRECT',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.13,
                                        color: Color(0xFFC70018),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Correct answer is',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currentQuestion.correctAnswer,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF13A007),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const Center(
                              child: Column(
                                children: [
                                  Text(
                                    'Tap screen to give answer',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            canJumpToNextQuestion
                ? Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: w,
                      height: .16 * h,
                      margin: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              final currentQuestionIndex = questionsList.indexOf(currentQuestion);
                              if (currentQuestionIndex == questionsList.length - 1) {
                                // last question
                                if (correctAnswerCount <= 3) {
                                  // Beginner
                                  Get.to(
                                      () => ResultPage(level: levelList.first, correctAnswerCount: correctAnswerCount));
                                } else if (correctAnswerCount <= 6) {
                                  // Intermediate
                                  Get.to(() => ResultPage(level: levelList[1], correctAnswerCount: correctAnswerCount));
                                } else {
                                  // Advanced
                                  Get.to(
                                      () => ResultPage(level: levelList.last, correctAnswerCount: correctAnswerCount));
                                }
                              } else {
                                // can go to next question
                                currentQuestion = questionsList[currentQuestionIndex + 1];
                                currentAnswer = '';
                                canJumpToNextQuestion = false;
                                isIncorrect = false;

                                _flutterTts.speak('${currentQuestion.question} ...Tap middle to answer.');
//                                _flutterTts.speak(currentQuestion.question);
//                                _flutterTts.speak("Tap middle to answer.");
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0FAB86),
                            surfaceTintColor: const Color(0xFF0FAB86),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                        child: const Text('Next Question'),
                      ),
                    ),
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      width: w,
                      height: .16 * h,
                      margin: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          checkGuess();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B93DF),
                            surfaceTintColor: const Color(0xFF0B93DF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key, required this.level, required this.correctAnswerCount});

  final Level level;
  final int correctAnswerCount;

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _flutterTts.speak(
          '''You have completed the test.Your level is ${widget.level.name}. Correct answer count is ${widget.correctAnswerCount}. .Your tutor is ${widget.level.tutor}. Tap the bottom to go to the home screen''');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0.2 * h,
            child: Column(
              children: [
                const Text(
                  'Hooray!!!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                const Text(
                  'You’ve completed\nthe test',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBFBFBF).withOpacity(.37),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Your level is ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.level.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF13A007),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Correct answers: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.correctAnswerCount}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Recommended Tutor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  widget.level.tutor,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.level.contact,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
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
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  _flutterTts.speak("Now you are in home.");
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B93DF),
                    surfaceTintColor: const Color(0xFF0B93DF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                child: const Text('Go to Home'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

final digitMap = <String, dynamic>{
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
  'read': 'red',
  'it': 'earth',
  'add': 'earth',
};
