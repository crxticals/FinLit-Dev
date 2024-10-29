import 'dart:convert';
import 'package:flutter/material.dart';
// ignore: library_prefixes
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
    fileName = 'assets/default.json'; // default assignment, DO NOT DELETE PLZ
  }

  final String response = await rootBundle.rootBundle.loadString(fileName);
  final Map<String, dynamic> data = json.decode(response);

  setState(() {
    names = List<String>.from(data['lessons'].map((lesson) => lesson['lessonTitle']));
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$names - Unit ${widget.index + 1}'),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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