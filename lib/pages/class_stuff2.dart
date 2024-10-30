import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;

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

    // Determine the name of the JSON file based on the index
    if (widget.index == 0) {
      fileName = 'assets/Unit1_L1.json';
    } else if (widget.index == 1) {
      fileName = 'assets/Unit2_L2.json';
    } else if (widget.index == 2) {
      fileName = 'assets/Unit3_L3.json';
    } else if (widget.index == 3) {
      fileName = 'assets/Unit4_L4.json';
    } else if (widget.index == 4) {
      fileName = 'assets/Unit5_L5.json';
    } else if (widget.index == 5) {
      fileName = 'assets/Unit6_L6.json';
    } else {
      fileName = 'assets/default.json';
    }

    // Load the JSON content
    final String response = await rootBundle.rootBundle.loadString(fileName);
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      // Use the widget.index to load the corresponding lesson
      lessonContent = data['lessons'][widget.interlessonindex]; // get the lesson based on index
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
                  ...List<Widget>.from(lessonContent!['questions'].map((question) {
                    return ListTile(
                      title: Text(question['question']),
                      subtitle: Text('Options: ${question['options'].join(', ')}'),
                    );
                  })),
                ],
              ),
            ),
    );
  }
}