import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finlit/pages/firestore_service_import.dart'; // Import your Firestore service

class MigrateData extends StatefulWidget {
  const MigrateData({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MigrateDataState createState() => _MigrateDataState();
}

class _MigrateDataState extends State<MigrateData> {
  final FirestoreServiceImport _firestoreService = FirestoreServiceImport();

  Future<void> _migrateData() async {
    // Load JSON data from assets
    final String jsonData = await rootBundle.loadString('assets/Unit6.json');
    final Map<String, dynamic> data = jsonDecode(jsonData);
    
    // Extract unitId from JSON structure
    final unitId = data['unit']; // Use the 'unit' key in your JSON

    // Iterate through lessons and add to Firestore with index as ID
    for (int lessonIndex = 0; lessonIndex < data['lessons'].length; lessonIndex++) {
      final lesson = data['lessons'][lessonIndex];
      await _firestoreService.addLesson(unitId, lessonIndex.toString(), lesson);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migrate Data'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _migrateData,
          child: const Text('Migrate Data to Firestore'),
        ),
      ),
    );
  }
}
