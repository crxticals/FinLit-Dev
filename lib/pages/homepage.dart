import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff1.dart';
// ignore: unused_import
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

final List imgAssets = [
  'assets/Unit1.png',
  'assets/Unit2.png',
  'assets/Unit3.png',
  'assets/Unit4.png',
  'assets/Unit5.png',
  'assets/Unit6.png'
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Set height as 70% of screen height
    final double adaptiveHeight = MediaQuery.of(context).size.height * 0.7;
    
    // Determine width multiplier based on platform
    const double widthMultiplier = kIsWeb ? 0.21 : 0.8;
    final double adaptiveWidth = MediaQuery.of(context).size.width * widthMultiplier;

    final List<Widget> imageSliders = imgAssets
        .asMap()
        .entries
        .map((entry) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      imageUrl: entry.value,
                      index: entry.key,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(5.0),
                width: adaptiveWidth, // Use adaptive width
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.asset(entry.value,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(),
                      ),
                    ],
                  ),
                ),
              ),
            ))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinLit'),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromRGBO(69, 80, 80, 1),
      body: Center(
        child: CarouselSlider(
          options: CarouselOptions(
            height: adaptiveHeight,
            enlargeCenterPage: true,
            enableInfiniteScroll: true,
            autoPlay: false,
          ),
          items: imageSliders,
        ),
      ),
    );
  }
}