import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff1.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_name/pages/login.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart'; // Add this line

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
  Map<String, double> unitProgress = {}; // Add this line
  final Color drawerColor = const Color(0xFF797a82);

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
      
      // Initialize progress data for each unit
      if (userData['progressStatus'] != null) {
        Map<String, dynamic> progressStatus = userData['progressStatus'];
        unitProgress = progressStatus.map((key, value) => 
          MapEntry(key, value.toDouble()));
      }
    });
  }

  double getUnitProgress(int index) {
    String unitName = imgAssets[index].split('/').last.split('.').first;
    return unitProgress[unitName] ?? 0.0;
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
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
          // Navigation Drawer with rounded corners
          Padding(
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 4,
              right: 4,
            ),
            child: Container(
              width: 280,
              decoration: BoxDecoration(
                color: drawerColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(2, 0),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 36),
                  const Text(
                    'FinLit',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  NavigationDrawerItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    isSelected: _selectedIndex == 0,
                    onTap: () => _onItemTapped(0),
                  ),
                  NavigationDrawerItem(
                    icon: Icons.translate_rounded,
                    label: 'Vocabulary',
                    isSelected: _selectedIndex == 1,
                    onTap: () => _onItemTapped(1),
                  ),
                  NavigationDrawerItem(
                    icon: Icons.quiz_rounded,
                    label: 'Tests',
                    isSelected: _selectedIndex == 2,
                    onTap: () => _onItemTapped(2),
                  ),
                  NavigationDrawerItem(
                    icon: Icons.leaderboard_rounded,
                    label: 'Leaderboard',
                    isSelected: _selectedIndex == 3,
                    onTap: () => _onItemTapped(3),
                  ),
                  const Spacer(),
                  // User Profile Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('profile.jpeg'),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          userData['name'] ?? 'User',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Level ${userData['level'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Settings and Account Section
                  NavigationDrawerItem(
                    icon: Icons.settings,
                    label: 'Settings',
                    isSelected: _selectedIndex == 4,
                    onTap: () => _onItemTapped(4),
                  ),
                  NavigationDrawerItem(
                    icon: Icons.person_outline,
                    label: 'Account',
                    isSelected: _selectedIndex == 5,
                    onTap: () => _onItemTapped(5),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Carousel Area
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
                              value = (1 - (value * 0.3)).clamp(0.0, 1.0);
                            }
                            
                            double progressPercentage = getUnitProgress(index); // Get the progress

                            return Transform.scale(
                              scale: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    GestureDetector(
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
                                    ArcProgressBar( // Add the progress bar here
                                      percentage: progressPercentage,
                                      arcThickness: 5,
                                      innerPadding: 16,
                                      animateFromLastPercent: true,
                                      handleSize: 10,
                                      backgroundColor: Colors.black12,
                                      foregroundColor: Colors.black,
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      child: Text(
                                        '${progressPercentage.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationDrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavigationDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFFE0E0E0) : const Color(0xFFCCCCCC),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? const Color(0xFFE0E0E0) : const Color(0xFFCCCCCC),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
