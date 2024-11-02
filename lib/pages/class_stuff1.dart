import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff2.dart';
import 'package:flutter/services.dart' as rootBundle;

class NameListScreen extends StatefulWidget {
  final String imageUrl;
  final int index;
  const NameListScreen({super.key, required this.imageUrl, required this.index});

  @override
  NameListScreenState createState() => NameListScreenState();
}

class NameListScreenState extends State<NameListScreen> {
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    loadNames();
  }

  Future<void> loadNames() async {
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
        fileName = 'assets/default.json'; // default assignment
    }

    final String response = await rootBundle.rootBundle.loadString(fileName);
    final Map<String, dynamic> data = json.decode(response);

    setState(() {
      names = List<String>.from(data['lessons'].map((lesson) => lesson['lessonTitle']));
    });
  }

  void navigateToDetail(int lessonIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContentListScreen(
          imageUrl: widget.imageUrl,
          index: widget.index, // use widget.index here
          interlessonindex: lessonIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unit ${widget.index + 1} Lesson Titles'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(names[index]),
            onTap: () => navigateToDetail(index),  // Pass the current lesson index
          );
        },
      ),
    );
  }
}