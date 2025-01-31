import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:finlit/pages/class_stuff1.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import 'package:finlit/pages/vocabulary.dart';
import 'package:finlit/pages/onboarding.dart';

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
  final List<Map<String, dynamic>> notifications = [
    {'title': 'New Achievement!', 'subtitle': 'Perfect Streak Week', 'time': '2h ago'},
    {'title': 'Lesson Completed', 'subtitle': 'Unit 1: Basics', 'time': '5h ago'},
    {'title': 'Rank Up!', 'subtitle': 'Now in Top 20%', 'time': '1d ago'},
  ];

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
        unitProgress = (userData['progressStatus'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value.toDouble()),
        );
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D3F6B), Color(0xFF121E28)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            // Left Sidebar
            _buildSidebar(),
            
            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Carousel Section
                    Expanded(
                      flex: 2,
                      child: _buildCarousel(),
                    ),
                    
                    // Notifications Section
                    SizedBox(
                      width: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: _buildNotificationsPanel(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
      child: GlassContainer(
        width: 320,
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
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
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
            ..._buildNavigationItems(),
            const Spacer(),
            _buildLessonProgress(),
            _buildStatsOverview(),
            _buildUserProfile(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildCarousel() {
    return GlassContainer(
      blur: 15,
      color: Colors.white.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: SizedBox(
          width: 350, // Adjust the width to 50% of the screen width
          child: CarouselSlider.builder(
            itemCount: imgAssets.length,
            itemBuilder: (context, index, realIndex) {
              double progressPercentage = getUnitProgress(index);
              
              return GlassContainer(
                blur: 15,
                color: Colors.white.withOpacity(0.1),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Unit Image with Hero Animation
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NameListScreen(
                            imageUrl: imgAssets[index],
                            index: index,
                          ),
                        ),
                      ),
                      child: Hero(
                        tag: 'image$index',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IntrinsicWidth(
                            child: Image.asset(
                              imgAssets[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Progress Circle
                    Positioned(
                      bottom: 300,
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: ArcProgressBar(
                          percentage: progressPercentage,
                          arcThickness: 5,
                          innerPadding: 16,
                          animateFromLastPercent: true,
                          handleSize: 10,
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.black,
                        ),
                      ),
                    ),
                    
                    // Progress Percentage Text
                  ],
                ),
              );
            },
            options: CarouselOptions(
              height: 800,  // Adjust the height to your desired value
              aspectRatio: 1/2,  // Adjust the aspect ratio to control the width relative to height
              viewportFraction: 0.6,  // Show part of next/previous items
              enableInfiniteScroll: true,
              enlargeCenterPage: true,  // Creates the hero effect
              enlargeFactor: 0.9,  // Adjust this for more/less dramatic scaling
              scrollDirection: Axis.horizontal,
              autoPlay: false,  // Disabled auto-play as it's an educational app
              onPageChanged: (index, reason) {
                // You can add page change handling here if needed
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsPanel() {
    return GlassContainer(
      blur: 8,
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.notifications_active, color: Colors.white),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return GlassContainer(
                  blur: 5,
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    title: Text(
                      notifications[index]['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notifications[index]['subtitle'],
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        Text(
                          notifications[index]['time'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.notification_important,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNavigationItems() {
    return [
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
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Vocabulary()),
        ),
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
    ];
  }

  Widget _buildUnitCard(int index, double scale) {
    double progressPercentage = getUnitProgress(index);
    return Transform.scale(
      scale: scale,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: GlassContainer(
          blur: 15,
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NameListScreen(
                      imageUrl: imgAssets[index],
                      index: index,
                    ),
                  ),
                ),
                child: Hero(
                  tag: 'image$index',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imgAssets[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: ArcProgressBar(
                    percentage: progressPercentage,
                    arcThickness: 5,
                    innerPadding: 16,
                    animateFromLastPercent: true,
                    handleSize: 10,
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.blueAccent,
                  ),
                ),
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
      ),
    );
  }

  Widget _buildLessonProgress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GlassContainer(
        blur: 8,
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Course Progress',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                animation: true,
                lineHeight: 8,
                percent: (userData['overallProgress'] ?? 0) / 100,
                progressColor: Colors.blueAccent,
                backgroundColor: Colors.white24,
                barRadius: const Radius.circular(10),
              ),
              const SizedBox(height: 8),
              Text(
                '${userData['overallProgress'] ?? 0}% Complete',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassContainer(
        blur: 8,
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(FontAwesomeIcons.crown, 'Rank', '#${userData['rank'] ?? 'N/A'}'),
              _buildStatItem(FontAwesomeIcons.fire, 'Streak', '${userData['dayStreak'] ?? '0'} Days'),
              _buildStatItem(FontAwesomeIcons.star, 'Level', '${userData['level'] ?? 'N/A'}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () {
          // Show a dialog or a menu with the logout option
          _showLogoutDialog(context);
        },
        child: GlassContainer(
          blur: 8,
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 24, // Smaller size for horizontal layout
                  backgroundImage: AssetImage('assets/profile.jpeg'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userData['name'] ?? 'User',
                      style: const TextStyle(
                        fontSize: 16,
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
                const Spacer(), // Pushes the logout icon to the end
                const Icon(
                  Icons.logout,
                  color: Colors.white,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Perform logout
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to the onboarding or login screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OnBoarding()),
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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