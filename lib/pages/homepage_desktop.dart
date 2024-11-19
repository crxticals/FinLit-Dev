import 'package:flutter/material.dart';
import 'package:FinLit/pages/class_stuff1.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:FinLit/pages/login.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

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
  Map<String, double> unitProgress = {};
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
      body: Container(
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
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                bottom: 4,
                right: 4,
              ),
              child: GlassContainer(
                width: 280,
                height: double.infinity,
                blur: 10,
                color: Colors.white.withOpacity(0.4),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.4),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
                border: Border.fromBorderSide(BorderSide.none),
                shadowStrength: 4,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                shadowColor: Colors.black.withOpacity(0.24),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    const Text(
                      'FinLit',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GlassContainer(
                        blur: 8,
                        color: Colors.white.withOpacity(0.1),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        border: Border.fromBorderSide(BorderSide.none),
                        shadowStrength: 4,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
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
                      ),
                    ),
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
            Expanded(
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
                            
                            double progressPercentage = getUnitProgress(index);

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
                                    SizedBox(
                                      width: 220,
                                      height: 220,
                                      child: ArcProgressBar(
                                        percentage: progressPercentage,
                                        arcThickness: 5,
                                        innerPadding: 16,
                                        animateFromLastPercent: true,
                                        handleSize: 10,
                                        backgroundColor: Colors.white24,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      child: Text(
                                        '${progressPercentage.toStringAsFixed(0)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
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
          ],
        ),
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
        child: GlassContainer(
          blur: isSelected ? 8 : 0,
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                )
              : null,
          border: Border.fromBorderSide(BorderSide.none),
          shadowStrength: isSelected ? 4 : 0,
          borderRadius: BorderRadius.circular(28),
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}