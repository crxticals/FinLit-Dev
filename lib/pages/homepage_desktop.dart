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
  final PageController _pageController = PageController(viewportFraction: 0.8);
  // ignore: unused_field
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
          // Permanent Navigation Drawer
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
                // User stats
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Hello, ${userData['name'] ?? 'User'}', style: const TextStyle(color: Colors.white)),
                      Text('Level: ${userData['level'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                      Text('Rank: #${userData['rank'] ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Stack(
              children: [
                Container(
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
                ),
                Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.all(16.0),
                      alignment: Alignment.center,
                      child: const Text(
                        '',
                        style: TextStyle(
                          fontSize: 1,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 400, // Set the width of the carousel
                          height: 800, // Set the height of the carousel
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
                                    value = (1 - (value * 0.1)).clamp(0.0, 1.0);
                                  }
                                  return Center(
                                    child: Transform.scale(
                                      scale: value,
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
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10.0),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child: Image.asset(
                                                imgAssets[index],
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}