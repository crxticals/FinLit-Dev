import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.4);
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

  // Sign out method
  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
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
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 1.0,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Hello, ${userData['name'] ?? 'User'}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 1),
                          const Text(
                            'Ready to learn?',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8), // Spacer
                          Row( // Wrap the button in a Row
                            mainAxisAlignment: MainAxisAlignment.start, // Align to the start of the row
                            children: [
                              ElevatedButton(
                                onPressed: _signOut,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white, 
                                  backgroundColor: Colors.red, // Text color
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Container(
                      color: const Color(0xFFF2F5EA),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Level'),
                              Text('${userData['level'] ?? 'N/A'}'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Rank'),
                              Text('Rank #${userData['rank'] ?? 'N/A'}'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Day Streak'),
                              Text('${userData['dayStreak'] ?? 'N/A'}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
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
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height * 0.6,
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
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(212, 242, 245, 234),
        selectedItemColor: const Color(0xFF121E28),
        unselectedItemColor: Colors.black,
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
