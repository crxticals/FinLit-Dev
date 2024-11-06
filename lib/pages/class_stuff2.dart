import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'quiz_display.dart'; // Import the quiz_display.dart file

class ContentListScreen extends StatefulWidget {
  final String imageUrl;
  final int index;
  final int interlessonindex;

  const ContentListScreen({super.key, required this.imageUrl, required this.index, required this.interlessonindex});

  @override
  ContentListScreenState createState() => ContentListScreenState();
}

class ContentListScreenState extends State<ContentListScreen> {
  Map<String, dynamic>? lessonContent;

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  Future<void> loadLesson() async {
    String fileName;

    switch (widget.index) {
      case 0:
        fileName = 'assets/Unit1.json';
        break;
      case 1:
        fileName = 'assets/Unit2.json';
        break;
      case 2:
        fileName = 'assets/Unit3.json';
        break;
      case 3:
        fileName = 'assets/Unit4.json';
        break;
      case 4:
        fileName = 'assets/Unit5.json';
        break;
      case 5:
        fileName = 'assets/Unit6.json';
        break;
      default:
        fileName = 'assets/default.json';
    }

    final String response = await rootBundle.rootBundle.loadString(fileName);
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      lessonContent = data['lessons'][widget.interlessonindex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit ${widget.index + 1} Lesson'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: lessonContent == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    lessonContent!['lessonTitle'],
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  ...List<Widget>.from(lessonContent!['ClassContent'].map((classContent) {
                    return Column(
                      children: List<Widget>.from(classContent['ReadingContent'].map((reading) {
                        return ListTile(
                          title: Text(reading),
                        );
                      })),
                    );
                  })),
                  // Adjust the onPressed method to pass interlessonindex to QuizPage
                  ElevatedButton(
                    onPressed: () {
                      String quizFileName = widget.index == 0 ? 'assets/Unit1.json' :
                                            widget.index == 1 ? 'assets/Unit2.json' :
                                            widget.index == 2 ? 'assets/Unit3.json' :
                                            widget.index == 3 ? 'assets/Unit4.json' :
                                            widget.index == 4 ? 'assets/Unit5.json' :
                                            widget.index == 5 ? 'assets/Unit6.json' :
                                            'assets/default_quiz.json';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(fileName: quizFileName, lessonIndex: widget.interlessonindex),
                        ),
                      );
                    },
                    child: const Text('Open Questions'),
                  ),
                ],
              ),
            ),
    );
  }
}