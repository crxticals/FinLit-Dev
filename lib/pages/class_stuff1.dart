import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff2.dart';
import 'package:flutter/services.dart' as rootBundle;

class NameListScreen extends StatefulWidget {
  final String imageUrl;
  final int index;
  final String imageTesturl = 'assets/Testing.webp';
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
          index: widget.index,
          interlessonindex: lessonIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Unit ${widget.index + 1} - Lessons'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image or Carousel section
              Image.asset(
                widget.imageTesturl, // using image URL for the header
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              const SizedBox(height: 16),
              Text(
                'Basic Budgets',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1 / 1.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => navigateToDetail(index),
                      child: Card(
                        color: Colors.green,
                        elevation: 5,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              names[index],
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
  }