import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:finlit/pages/class_stuff1.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:finlit/pages/onboarding.dart';
import 'package:flutter/gestures.dart';

final List<String> imgAssets = [
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
  final PageController _pageController = PageController(viewportFraction: 0.4);
  int _selectedIndex = 0;
  Map<String, dynamic> userData = {};
  Map<String, double> unitProgress = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final String response = await rootBundle.loadString('assets/user_data.json');
      final data = json.decode(response);
      setState(() {
        userData = data['user'] ?? {};
        if (userData['progressStatus'] != null) {
          Map<String, dynamic> progressStatus = userData['progressStatus'];
          unitProgress = progressStatus.map((key, value) => 
            MapEntry(key, value.toDouble()));
        }
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  double getUnitProgress(int index) {
    String unitName = imgAssets[index].split('/').last.split('.').first;
    return unitProgress[unitName] ?? 0.0;
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

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => OnBoarding()));
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;
    // Calculate the available height for the carousel
    final double topPadding = MediaQuery.of(context).padding.top;
    final double headerHeight = 120; // Approximate height for the header
    final double statsHeight = 120; // Approximate height for the stats container
    final double spacing = 24; // Spacing between elements
    final double bottomNavHeight = 56; // Standard bottom navigation height
    
    // Calculate the carousel height
    final double carouselHeight = screenSize.height - 
        (topPadding + headerHeight + statsHeight + spacing + bottomNavHeight);

    return Scaffold(
      body: Stack(
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
          Listener(
            onPointerSignal: (PointerSignalEvent pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final offset = pointerSignal.scrollDelta.dy;
                _pageController.position.moveTo(
                  _pageController.offset + offset,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              }
            },

            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(16.0, topPadding + 16.0, 16.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${userData['name'] ?? 'User'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ready to learn?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _signOut,
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                // User Stats
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Level', '${userData['level'] ?? 'N/A'}', Icons.star),
                      _buildStatItem('Rank', 'Rank #${userData['rank'] ?? 'N/A'}', Icons.leaderboard),
                      _buildStatItem('Day Streak', '${userData['dayStreak'] ?? 'N/A'}', Icons.local_fire_department),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Unit Cards with Progress Bar
                SizedBox(
                  height: carouselHeight,
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
                          double progressPercentage = getUnitProgress(index);
                          
                          // Calculate the dimensions for the card
                          double cardWidth = screenSize.width * 0.8;
                          double cardHeight = carouselHeight * 0.9; // Leave some padding
                          
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
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: SizedBox(
                                      width: cardWidth,
                                      height: cardHeight,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: cardWidth,
                                            height: cardHeight,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(imgAssets[index]),
                                                fit: BoxFit.contain, // Changed from cover to contain
                                              ),
                                              color: Colors.black.withOpacity(0.1), // Optional: adds a subtle background
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            child: Container(
                                              width: cardWidth * 0.8,
                                              height: 5,
                                              decoration: BoxDecoration(
                                                color: Colors.black12,
                                                borderRadius: BorderRadius.circular(2.5),
                                              ),
                                              child: LinearProgressIndicator(
                                                value: progressPercentage,
                                                backgroundColor: Colors.transparent,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                              ),
                                            ),
                                          ),
                                        ],
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
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF121E28),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}