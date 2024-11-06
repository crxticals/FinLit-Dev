import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' as rootBundle;

class QuizPage extends StatefulWidget {
  final String fileName;

  const QuizPage({super.key, required this.fileName});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  List<dynamic> questions = [];
  int currentQuestionIndex = 0;
  int score = 0; // Track the user's score
  bool showFeedback = false;
  String feedbackMessage = '';
  late AnimationController _animationController;
  late Animation<Color?> _feedbackColorAnimation;

  @override
  void initState() {
    super.initState();
    loadQuestions();

    // Initialize animation controller and feedback animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _feedbackColorAnimation = ColorTween().animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadQuestions() async {
    final String response = await rootBundle.rootBundle.loadString(widget.fileName);
    final data = json.decode(response);

    setState(() {
      questions = data['lessons'][0]['questions'];
    });
  }

  void answerQuestion(String option) {
    // Check if answer is correct
    bool correct = option == questions[currentQuestionIndex]['correctAnswer'];
    setState(() {
      showFeedback = true;
      feedbackMessage = correct ? 'Correct' : 'Incorrect';
      if (correct) score++; // Increase score for correct answers
      _feedbackColorAnimation = ColorTween(
        begin: Colors.transparent,
        end: correct ? Colors.green.withOpacity(0.7) : Colors.red.withOpacity(0.7),
      ).animate(_animationController);
    });

    // Start animation and advance to next question after delay
    _animationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _animationController.reverse();
        setState(() {
          showFeedback = false;
          if (currentQuestionIndex < questions.length - 1) {
            currentQuestionIndex++;
          } else {
            // Show score and reset currentQuestionIndex to the last screen
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
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Go back to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                  style: const TextStyle(fontSize: 18),
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
            FadeTransition(
              opacity: _animationController,
              child: Container(
                color: _feedbackColorAnimation.value,
                child: Center(
                  child: Text(
                    feedbackMessage,
                    style: const TextStyle(fontSize: 36, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
