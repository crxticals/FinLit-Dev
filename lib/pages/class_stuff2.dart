import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:carousel_slider/carousel_slider.dart';
import 'quiz_display.dart';

class ContentListScreen extends StatefulWidget {
  final String imageUrl;
  final int index;
  final int interlessonindex;

  const ContentListScreen({
    super.key,
    required this.imageUrl,
    required this.index,
    required this.interlessonindex,
  });

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

    try {
      final String response = await rootBundle.rootBundle.loadString(fileName);
      final Map<String, dynamic> data = json.decode(response);

      setState(() {
        lessonContent = data['lessons'][widget.interlessonindex];
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading lesson: $e');
      }
    }
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
          : Column(
              children: [
                Text(
                  lessonContent!['lessonTitle'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400.0,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                  ),
                  items: [
                    ...lessonContent!['ClassContent'].map<Widget>((classContent) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List<Widget>.from(classContent['ReadingContent'].map<Widget>((reading) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  reading,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            })),
                          ),
                        ),
                      );
                    }).toList(),
                    ...lessonContent!['flashCards'].map<Widget>((flashCard) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                flashCard['term'],
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                flashCard['definition'],
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
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
    );
  }
}
