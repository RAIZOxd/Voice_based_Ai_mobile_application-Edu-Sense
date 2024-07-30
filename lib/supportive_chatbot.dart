import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'common_methods.dart';

class SupportiveChatBot extends StatefulWidget {
  const SupportiveChatBot({super.key});

  @override
  State<SupportiveChatBot> createState() => _SupportiveChatBotState();
}

class _SupportiveChatBotState extends State<SupportiveChatBot> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _botAnswer = '';

  final TextEditingController _questionController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      flutterTts.speak(
          'Welcome to Voice Bot. Tap middle to ask anything. Double tap middle to read answer again. Tap bottom right to submit question. Tap bottom left to ask new question. Swipe right to go home.');
    });

    super.initState();
  }

  void askQuestion() async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "What are the seven colors in rainbow?",
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      seed: 6,
      messages: [systemMessage],
      temperature: 0.2,
      maxTokens: 100,
    );

    print(chatCompletion.choices.first.message); // ...
    print(chatCompletion.systemFingerprint); // ...
    print(chatCompletion.usage.promptTokens); // ...
    print(chatCompletion.id);
  }

  void askQuestionGemini() async {
    final gemini = Gemini.instance;

    try {
      final chatCompletion = await gemini.text(
        _questionController.text,
        generationConfig: GenerationConfig(
          maxOutputTokens: 100,
          temperature: 0.2,
        ),
      );
      // print("text response =========");
      // print(chatCompletion?.toJson());
      // final result = chatCompletion?.content?.parts?.last.text ?? '';
      StringBuffer resultBuffer = StringBuffer("");

      if (chatCompletion?.content?.parts != null) {
        for (var part in chatCompletion!.content!.parts!) {
          resultBuffer.write(part.text ?? '');
        }
      }

      if (mounted) {
        setState(() {
          if (resultBuffer.isEmpty) {
            _botAnswer = "Please ask another question.";
          } else {
            _botAnswer = resultBuffer.toString();
          }
        });
      }
    } catch (e) {
      var x = 10;
      print("Error while fetching data");
      print(e);
    }
  }

  void geminiModels() async {
    final gemini = Gemini.instance;
    final modelList = await gemini.listModels();
    print(modelList);
  }

  void resetPage() {
    if (mounted) {
      setState(() {
        _botAnswer = '';
      });
    }
    _questionController.clear();
  }

  @override
  void dispose() {
    _speechToText.stop();
    super.dispose();
  }

  void startListening() async {
    if (await _speechToText.initialize()) {
      _speechToText.listen(
        pauseFor: const Duration(milliseconds: 2500),
        onResult: (result) {
          if (result.finalResult) {
            _questionController.text = result.recognizedWords;
            _speechToText.stop();

            // set state
            if (mounted) {
              setState(() {});
            }

            // Tell to submit
            Future.delayed(const Duration(milliseconds: 1000), () {
              flutterTts.speak("Tap bottom right to submit");
            });
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onPanUpdate: (details) {
        // Swiping in right direction.
        if (details.delta.dx > 0 && details.delta.dy == 0) {
          debugPrint("swiping left to right");
          flutterTts.stop();
          Get.back();
          speak('Now you are in Home screen');
        }
      },
      onTap: () async {
        resetPage();
        // await flutterTts.speak("Ask.");
        Future.delayed(const Duration(milliseconds: 1000), () {
          startListening();
        });
      },
      onDoubleTap: () {
        if (_botAnswer.isNotEmpty) {
          flutterTts.speak(_botAnswer);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: .04 * h, left: .04 * w, right: .04 * w),
                        child: TextFormField(
                          controller: _questionController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          onTapOutside: (event) => FocusScope.of(context).unfocus(),
                          maxLength: 100,
                          decoration: InputDecoration(
                            hintText: 'Ask anything...',
                            labelText: 'Ask anything',
                            // counter: const SizedBox.shrink(),
                            hintStyle: const TextStyle(fontWeight: FontWeight.w400),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            labelStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.8,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1.8,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                          ),
                          cursorColor: Colors.black,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Question is required";
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: w * 0.85,
                        height: h * 0.6,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: const Color(0xFF7740EB),
                            width: 1.4,
                          ),
                        ),
                        child: SingleChildScrollView(
                          controller: ScrollController(),
                          child: Text(_botAnswer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.47,
                    height: MediaQuery.of(context).size.height * 0.16,
                    margin: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                    child: ValueListenableBuilder(
                      valueListenable: _questionController,
                      builder: (context, value, _) {
                        return ElevatedButton(
                          onPressed: value.text.isNotEmpty && _botAnswer.isNotEmpty ? () => resetPage() : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2EB11B),
                              surfaceTintColor: const Color(0xFF2EB11B),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFA8E59F),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                          child: const Text('Ask New\nQuestion', textAlign: TextAlign.center),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.47,
                    height: MediaQuery.of(context).size.height * 0.16,
                    margin: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                    child: ValueListenableBuilder(
                      valueListenable: _questionController,
                      builder: (context, value, _) {
                        return ElevatedButton(
                          onPressed: value.text.isNotEmpty
                              ? () {
                                  // Navigator.of(context).popUntil((route) => route.isFirst);
                                  // speak("Now you are in home.");
                                  if (_formKey.currentState!.validate()) {
                                    askQuestionGemini();
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B93DF),
                              surfaceTintColor: const Color(0xFF0B93DF),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF8CCFF5),
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11))),
                          child: const Text('Submit\nQuestion', textAlign: TextAlign.center),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

var openAiModelList = {
  "object": "list",
  "data": [
    {"id": "dall-e-3", "object": "model", "created": 1698785189, "owned_by": "system"},
    {"id": "whisper-1", "object": "model", "created": 1677532384, "owned_by": "openai-internal"},
    {"id": "davinci-002", "object": "model", "created": 1692634301, "owned_by": "system"},
    {"id": "babbage-002", "object": "model", "created": 1692634615, "owned_by": "system"},
    {"id": "dall-e-2", "object": "model", "created": 1698798177, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-16k", "object": "model", "created": 1683758102, "owned_by": "openai-internal"},
    {"id": "tts-1-hd-1106", "object": "model", "created": 1699053533, "owned_by": "system"},
    {"id": "tts-1-hd", "object": "model", "created": 1699046015, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-1106", "object": "model", "created": 1698959748, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-instruct-0914", "object": "model", "created": 1694122472, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-instruct", "object": "model", "created": 1692901427, "owned_by": "system"},
    {"id": "tts-1", "object": "model", "created": 1681940951, "owned_by": "openai-internal"},
    {"id": "gpt-3.5-turbo-0301", "object": "model", "created": 1677649963, "owned_by": "openai"},
    {"id": "tts-1-1106", "object": "model", "created": 1699053241, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-0125", "object": "model", "created": 1706048358, "owned_by": "system"},
    {"id": "text-embedding-3-large", "object": "model", "created": 1705953180, "owned_by": "system"},
    {"id": "gpt-3.5-turbo", "object": "model", "created": 1677610602, "owned_by": "openai"},
    {"id": "text-embedding-3-small", "object": "model", "created": 1705948997, "owned_by": "system"},
    {"id": "gpt-3.5-turbo-0613", "object": "model", "created": 1686587434, "owned_by": "openai"},
    {"id": "text-embedding-ada-002", "object": "model", "created": 1671217299, "owned_by": "openai-internal"},
    {"id": "gpt-3.5-turbo-16k-0613", "object": "model", "created": 1685474247, "owned_by": "openai"}
  ]
};

const sampleLongText = '''What is Lorem Ipsum?
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

Why do we use it?
It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).


Where does it come from?
Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.

The standard chunk of Lorem Ipsum used since the 1500s is reproduced below for those interested. Sections 1.10.32 and 1.10.33 from "de Finibus Bonorum et Malorum" by Cicero are also reproduced in their exact original form, accompanied by English versions from the 1914 translation by H. Rackham.''';
