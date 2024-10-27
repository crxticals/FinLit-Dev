import 'package:flutter/material.dart';
import 'package:project_name/pages/homepage.dart';

final List imgAssets =[
  'assets/Unit1.png',
  'assets/Unit2.png',
  'assets/Unit3.png',
  'assets/Unit4.png',
  'assets/Unit5.png',
  'assets/Unit6.png'
];

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