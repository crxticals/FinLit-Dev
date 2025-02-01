import 'dart:async';
import 'package:finlit/pages/homepage.dart';
import 'package:finlit/pages/homepage_desktop.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPreferencesPage extends StatefulWidget {
  @override
  _UserPreferencesPageState createState() => _UserPreferencesPageState();
}

class _UserPreferencesPageState extends State<UserPreferencesPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedLanguage = 'English';
  int _selectedExperience = 1;
  bool _notificationsEnabled = true;

  final List<String> _languages = ['English', 'Vietnamese'];
  final List<int> _experienceLevels = [1, 5, 8];

  Future<void> _savePreferences() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'language': _selectedLanguage,
          'experience': _selectedExperience,
          'notifications': _notificationsEnabled,
          'first_time?': "False",
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preferences saved successfully!')),
        );

        // Navigate to the appropriate homepage
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  final constraints = MediaQuery.of(context).size;
                  return (constraints.width > constraints.height)
                      ? const HomeScreen1() // Landscape
                      : const HomeScreen(); // Portrait
                },
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Preferences'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedLanguage,
                items: _languages.map((String language) {
                  return DropdownMenuItem<String>(
                    value: language,
                    child: Text(language),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Language'),
              ),
              DropdownButtonFormField<int>(
                value: _selectedExperience,
                items: _experienceLevels.map((int level) {
                  return DropdownMenuItem<int>(
                    value: level,
                    child: Text(level.toString()),
                  );
                }).toList(),
                onChanged: (int? newValue) {
                  setState(() {
                    _selectedExperience = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Experience Level'),
              ),
              SwitchListTile(
                title: Text('Enable Notifications'),
                value: _notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePreferences,
                child: Text('Save Preferences'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
