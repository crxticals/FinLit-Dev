import 'package:flutter/material.dart';
import 'package:project_name/pages/class_stuff1.dart';
// ignore: unused_import
import 'dart:io' show Platform;

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
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _selectedIndex = 0;

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
    final double adaptiveHeight = MediaQuery.of(context).size.height * 0.85;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinLit'),
        centerTitle: true,
      ),
      backgroundColor: const Color.fromARGB(255, 44, 54, 63),
      body: Center(
        child: SizedBox(
          height: adaptiveHeight,
          width: MediaQuery.of(context).size.width,
          child: PageView.builder(
            controller: _pageController,
            itemCount: imgAssets.length,
            itemBuilder: (context, index) => GestureDetector(
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
              child: Center(
                child: Hero(
                  tag: index,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 50,
                      height: adaptiveHeight,
                      child: Image.asset(
                        imgAssets[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(212, 242, 245, 234),
        selectedItemColor: const Color.fromRGBO(242, 255, 207, 1),
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