import 'dart:convert';
import 'package:flutter/material.dart';
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
  final String response = await rootBundle.rootBundle.loadString('assets/Unit1_L1.json');
  final Map<String, dynamic> data = json.decode(response);
  setState(() {
    names = List<String>.from(data['lessons'].map((lesson) => lesson['lessonTitle']));
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson View - Unit ${widget.index + 1}'),
      ),
      backgroundColor: const Color.fromRGBO(69, 80, 80, 1),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(names[index]),
          );
        }
      ),
    );
  }
}