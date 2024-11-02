import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as rootBundle;

class QuizPage extends StatefulWidget {
  final String fileName; 
  
  const QuizPage({super.key, required this.fileName});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String response = await rootBundle.rootBundle.loadString(widget.fileName);
    final data = json.decode(response);

    setState(() {
      questions = data['lessons'][0]['questions'];
    });
  }

  void answerQuestion(String option) {
    // Logic for answering the question can be implemented here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quiz")),
      body: questions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  questions[currentQuestionIndex]['question'],
                  style: const TextStyle(fontSize: 24),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...questions[currentQuestionIndex]['options'].map<Widget>((option) {
                  return ElevatedButton(
                    onPressed: () => answerQuestion(option),
                    child: Text(option),
                  );
                }).toList(),
                const SizedBox(height: 20),
                if (currentQuestionIndex < questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    },
                    child: const Text("Next Question"),
                  ),
              ],
            ),
    );
  }
}