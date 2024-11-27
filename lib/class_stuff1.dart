import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:FinLit/class_stuff2.dart';
import 'package:FinLit/firestore_service.dart';

class NameListScreen extends StatefulWidget {
  final String imageUrl;
  final int index;
  final String imageTesturl = 'assets/Testing.webp';
  const NameListScreen({super.key, required this.imageUrl, required this.index});

  @override
  NameListScreenState createState() => NameListScreenState();
}

class NameListScreenState extends State<NameListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> lessons = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  Future<void> loadLessons() async {
    try {
      setState(() => isLoading = true);
      
      // Get the unit name based on the index
      String unitName = _firestoreService.getUnitName(widget.index);
      
      // Fetch lessons for this unit
      final lessonData = await _firestoreService.getLessons(unitName);
      
      setState(() {
        lessons = lessonData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading lessons: $e';
        isLoading = false;
      });
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
        title: Text(_firestoreService.getUnitName(widget.index)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
              'Lessons',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading 
                ? const Center(child: CircularProgressIndicator())
                : error != null
                  ? Center(child: Text(error!))
                  : CarouselSlider.builder(
                      itemCount: lessons.length,
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
                                  lessons[index]['lessonTitle'] ?? 'Untitled Lesson',
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
      // Bottom navigation bar remains the same
    );
  }
}