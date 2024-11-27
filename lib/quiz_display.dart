import 'package:flutter/material.dart';
import 'package:FinLit/firestore_service.dart';

class QuizPage extends StatefulWidget {
  final String unitName;
  final int lessonIndex;

  const QuizPage({super.key, required this.unitName, required this.lessonIndex});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  bool showFeedback = false;
  String feedbackMessage = '';
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<Color?> _feedbackColorAnimation;

  @override
  void initState() {
    super.initState();
    loadQuestions();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    try {
      final questionData = await _firestoreService.getQuizQuestions(
        widget.unitName,
        widget.lessonIndex,
      );

      setState(() {
        questions = questionData;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void answerQuestion(String option) {
    bool correct = option == questions[currentQuestionIndex]['correctAnswer'];
    setState(() {
      showFeedback = true;
      feedbackMessage = correct ? 'Correct' : 'Incorrect';
      if (correct) score++;

      _feedbackColorAnimation = ColorTween(
        begin: Colors.transparent,
        end: correct ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
      ).animate(_animationController);
    });

    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _animationController.reverse();
        setState(() {
          showFeedback = false;
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
          } else {
            _showScoreDialog();
          }
        });
      });
    });
  }

  void _showScoreDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('Your score is: $score/${questions.length}'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          questions.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey,
                        color: const Color(0xFFE75A7C), // Set the color to E75A7C
                        minHeight: 10,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 4,
                        child: Center(
                          child: Text(
                            questions[currentQuestionIndex]['question'],
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: ListView.builder(
                          itemCount: questions[currentQuestionIndex]['options'].length,
                          itemBuilder: (context, index) {
                            String option = questions[currentQuestionIndex]['options'][index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                onPressed: () => answerQuestion(option),
                                child: Text(
                                  option,
                                  style: const TextStyle(fontSize: 18, color: Color(0xFFF2F5EA)), // Set the text color to F2F5EA
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          if (showFeedback)
            AnimatedBuilder(
              animation: _feedbackColorAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _animationController,
                  child: Container(
                    color: _feedbackColorAnimation.value,
                    child: Center(
                      child: Text(
                        feedbackMessage,
                        style: const TextStyle(fontSize: 36, color: Colors.black),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
