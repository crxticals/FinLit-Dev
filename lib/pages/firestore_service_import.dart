import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServiceImport {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a lesson to a specific unit
  Future<void> addLesson(String unitId, String lessonId, Map<String, dynamic> lesson) async {
    // Prepare lesson data for Firestore
    final lessonData = {
      'lessonTitle': lesson['lessonTitle'],
      'lessonIndex': lessonId, // Use lessonId as lessonIndex
      'ClassContent': lesson['ClassContent'],
      'questions': lesson['questions'],
      'flashCards': lesson['flashCards'],
    };

    await _db
        .collection('Units') // Collection for Units
        .doc(unitId) // Specific Unit document (e.g., Unit-1)
        .collection('lessons') // Collection for lessons within the unit
        .doc(lessonId) // Use lessonId as the document ID
        .set(lessonData); // Set the lesson data to Firestore
  }
}