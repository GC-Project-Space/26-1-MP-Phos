import 'package:flutter/material.dart';
import 'dart:ui';
// 탭에 들어갈 화면들 import
import 'home_screen.dart';
import 'gallery_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const GalleryScreen(),
    const Center(child: Text('Studio Screen (준비 중)')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.7),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF9D72FF),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.camera_alt, 0),
                  label: 'START',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.photo_library, 1),
                  label: 'GALLERY',
                ),
                BottomNavigationBarItem(
                  icon: _buildNavIcon(Icons.brush, 2),
                  label: 'STUDIO',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF9D72FF) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
      ),
    );
  }
}