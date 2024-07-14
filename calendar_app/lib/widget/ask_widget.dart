import '../env.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/material.dart';

class AskAiPage extends StatefulWidget {
  const AskAiPage({super.key});

  @override
  State<AskAiPage> createState() => _AskAiState();
}

class _AskAiState extends State<AskAiPage> {
  List<BubbleSpecialThree> questionAnswers = [
    const BubbleSpecialThree(
      text: 'Xin chào, tôi có thể giúp gì cho bạn ?',
      isSender: false,
    )
  ];
  final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  Future<void> getAnswer(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    setState(() {
      questionAnswers.add(BubbleSpecialThree(
        text: response.text != null
            ? response.text!
            : "Failed to generate answer. Please try again",
        isSender: false,
      ));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt câu hỏi AI'),
      ),
      backgroundColor: const Color.fromARGB(255, 17, 151, 148),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
              child: Column(children: questionAnswers.map((e) => e).toList()),
            ),
          ),
          MessageBar(
            messageBarHintText: 'Nhập câu hỏi ở đây',
            onSend: (prompt) => {
              setState(() {
                questionAnswers.add(BubbleSpecialThree(
                  text: prompt,
                  color: Colors.blue,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                ));
              }),
              getAnswer(prompt)
            },
          ),
        ],
      ),
    );
  }
}
