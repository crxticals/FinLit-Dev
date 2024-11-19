import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Get all lessons for a specific unit
  Future<List<Map<String, dynamic>>> getLessons(String unitName) async {
    try {
      // Get the lessons collection for the specific unit
      QuerySnapshot lessonsSnapshot = await _db
          .collection('Units')
          .doc(unitName)
          .collection('lessons')
          .get();

      List<Map<String, dynamic>> lessons = [];
      
      // Sort the documents based on their numeric IDs
      var sortedDocs = lessonsSnapshot.docs.toList()
        ..sort((a, b) => int.parse(a.id).compareTo(int.parse(b.id)));

      for (var doc in sortedDocs) {
        lessons.add(doc.data() as Map<String, dynamic>);
      }

      return lessons;
    } catch (e) {
      print('Error getting lessons: $e');
      rethrow;
    }
  }

  // Get specific lesson content using numeric ID
  Future<Map<String, dynamic>> getLessonContent(String unitName, int lessonId) async {
    try {
      DocumentSnapshot lessonDoc = await _db
          .collection('Units')
          .doc(unitName)
          .collection('lessons')
          .doc(lessonId.toString())
          .get();

      if (!lessonDoc.exists || lessonDoc.data() == null) {
        throw Exception('Lesson not found');
      }

      return lessonDoc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error getting lesson content: $e');
      rethrow;
    }
  }

  // Get all unit names
  Future<List<String>> getUnitNames() async {
    try {
      QuerySnapshot unitsSnapshot = await _db
          .collection('Units')
          .get();

      return unitsSnapshot.docs
          .map((doc) => doc.id)
          .toList();
    } catch (e) {
      print('Error getting unit names: $e');
      rethrow;
    }
  }

  // Get quiz questions for a specific lesson
  Future<List<Map<String, dynamic>>> getQuizQuestions(String unitName, int lessonId) async {
    try {
      DocumentSnapshot lessonDoc = await _db
          .collection('Units')
          .doc(unitName)
          .collection('lessons')
          .doc(lessonId.toString())
          .get();

      if (!lessonDoc.exists || lessonDoc.data() == null) {
        throw Exception('Lesson not found');
      }

      Map<String, dynamic> lessonData = lessonDoc.data() as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(lessonData['questions'] ?? []);
    } catch (e) {
      print('Error getting quiz questions: $e');
      rethrow;
    }
  }

  // Helper method to convert unit index to name
  String getUnitName(int index) {
    switch (index) {
      case 0:
        return '401k and Retirement';
      case 1:
        return 'Budgeting';
      case 2:
        return 'Debt';
      case 3:
        return 'Investing';
      case 4:
        return 'Taxes';
      case 5:
        return 'Understanding Consumer Protection';
      default:
        return 'Unknown Unit';
    }
  }
}