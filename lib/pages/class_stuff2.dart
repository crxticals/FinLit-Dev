import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:FinLit/pages/firestore_service.dart';
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
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? lessonContent;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLesson();
  }

  Future<void> loadLesson() async {
    try {
      // Get the unit name based on the index
      String unitName = _firestoreService.getUnitName(widget.index);
      
      // Fetch lesson content from Firestore
      final content = await _firestoreService.getLessonContent(
        unitName,
        widget.interlessonindex,
      );

      setState(() {
        lessonContent = content;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading lesson: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit ${widget.index + 1} Lesson'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lessonContent == null
              ? const Center(child: Text('Error loading lesson content'))
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
                        ...List<Widget>.from(lessonContent!['ClassContent'].map((classContent) {
                          return Card(
                            elevation: 0,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List<Widget>.from(classContent['ReadingContent'].map((reading) {
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
                        })),
                        ...List<Widget>.from(lessonContent!['flashCards'].map((flashCard) {
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
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                        })),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String unitName = _firestoreService.getUnitName(widget.index);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizPage(
                              unitName: unitName,
                              lessonIndex: widget.interlessonindex,
                            ),
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