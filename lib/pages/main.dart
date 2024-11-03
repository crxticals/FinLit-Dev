import 'package:flutter/material.dart';
import 'package:project_name/pages/homepage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'FinLit',
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}      