// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff1.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

final List<String> imgAssets = [
  'assets/Unit1.png',
  'assets/Unit2.png',
  'assets/Unit3.png',
  'assets/Unit4.png',
  'assets/Unit5.png',
  'assets/Unit6.png'
];

class HomeScreen1 extends StatefulWidget {
  const HomeScreen1({super.key});

  @override
  State<HomeScreen1> createState() => _HomeScreenState1();
}

class _HomeScreenState1 extends State<HomeScreen1> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _selectedIndex = 0;
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final String response = await rootBundle.loadString('assets/user_data.json');
    final data = json.decode(response);
    setState(() {
      userData = data['user'] ?? {};
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Drawer
          Container(
            width: 250,
            color: Colors.black,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'FinLit',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: const Text('Home', style: TextStyle(color: Colors.white)),
                  onTap: () => _onItemTapped(0),
                ),
                ListTile(
                  leading: const Icon(Icons.book, color: Colors.white),
                  title: const Text('Vocabulary', style: TextStyle(color: Colors.white)),
                  onTap: () => _onItemTapped(1),
                ),
                ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.white),
                  title: const Text('Tests', style: TextStyle(color: Colors.white)),
                  onTap: () => _onItemTapped(2),
                ),
                ListTile(
                  leading: const Icon(Icons.leaderboard, color: Colors.white),
                  title: const Text('Leader board', style: TextStyle(color: Colors.white)),
                  onTap: () => _onItemTapped(3),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Hello, ${userData['name'] ?? 'User'}', 
                          style: const TextStyle(color: Colors.white)),
                      Text('Level: ${userData['level'] ?? 'N/A'}', 
                          style: const TextStyle(color: Colors.white)),
                      Text('Rank: #${userData['rank'] ?? 'N/A'}', 
                          style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Carousel Area with Gradient Background
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3D3F6B),
                    Color(0xFF121E28),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: SizedBox(
                    width: 400,
                    height: 600,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: imgAssets.length,
                      itemBuilder: (context, index) {
                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double value = 1.0;
                            if (_pageController.position.haveDimensions) {
                              value = (_pageController.page! - index).abs();
                              value = 1 - (value * 0.3).clamp(0.0, 1.0);
                            }
                            return Transform.scale(
                              scale: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NameListScreen(
                                    imageUrl: imgAssets[index],
                                    index: index,
                                  ),
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'image$index',
                              child: Image.asset(
                                imgAssets[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}