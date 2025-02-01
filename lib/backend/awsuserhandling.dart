import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:s3_storage/s3_storage.dart';

class UserDataStorage {
  final String bucketName = 'your-app-user-data';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late S3Storage _s3Storage;

  UserDataStorage() {
    _s3Storage = S3Storage(
      region: 'us-east-1',
      accessKey: 'YOUR_ACCESS_KEY',
      secretKey: 'YOUR_SECRET_KEY', endPoint: ''
    );
  }

  Future<void> saveUserProgress(Map<String, dynamic> progressData) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    String key = 'user_progress/${currentUser.uid}.json';
    
  }

  Future<Map<String, dynamic>> getUserProgress() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    String key = 'user_progress/${currentUser.uid}.json';
    
    try {
      var result = await _s3Storage.downloadFile(key);
      return json.decode(utf8.decode(result));
    } catch (e) {
      return {};
    }
  }
}

extension on S3Storage {
  downloadFile(String key) {}
}