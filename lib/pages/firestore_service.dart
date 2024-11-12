import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add a lesson to a specific unit
  Future<void> addLesson(String unitId, Map<String, dynamic> lesson) async {
    // Prepare lesson data for Firestore
    final lessonData = {
      'lessonTitle': lesson['lessonTitle'],
      'lessonIndex': lesson['lessonIndex'],
      'ClassContent': lesson['ClassContent'],
      'questions': lesson['questions'],
      'flashCards': lesson['flashCards'],
    };

    await _db
        .collection('Units')              // Collection for Units
        .doc(unitId)                     // Specific Unit document (e.g., Unit-1)
        .collection('lessons')           // Collection for lessons within the unit
        .add(lessonData);                // Add the lesson data to Firestore
  }
}