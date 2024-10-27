import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String imageUrl;
  final int index;

  const DetailScreen({super.key, required this.imageUrl, required this.index});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lesson View - Unit $index'),
      ),
      backgroundColor: const Color.fromRGBO(69, 80, 80, 1),
    );
  }
}