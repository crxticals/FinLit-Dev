import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff2.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:carousel_slider/carousel_slider.dart';

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
        fileName = 'assets/default.json'; 
    }

    try {
      final String response = await rootBundle.rootBundle.loadString(fileName);
      final Map<String, dynamic> data = json.decode(response);

      setState(() {
        names = List<String>.from(data['lessons'].map((lesson) => lesson['lessonTitle'] ?? 'Unknown Lesson Title'));
      });

    } catch (e) {
      // ignore: avoid_print
      print('Error loading names: $e');
    }
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
          Image.asset(
            widget.imageTesturl,
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
            child: names.isEmpty
              ? const Center(child: CircularProgressIndicator()) // Show loading indicator while names are loaded
              : CarouselSlider.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index, realIndex) {
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
                  options: CarouselOptions(
                    height: 250,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                  ),
                ),
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(
      backgroundColor: Colors.blueGrey[900],
      selectedItemColor: Colors.tealAccent,
      unselectedItemColor: Colors.grey,
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
        ),
      ],
    ),
  );
  }
}