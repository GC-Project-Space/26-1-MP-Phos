import 'package:flutter/material.dart';
import 'screens/main_layout.dart'; // 분리한 레이아웃 파일 import

void main() {
  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Phos',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        primaryColor: const Color(0xFF9D72FF),
        fontFamily: 'Roboto',
      ),
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
    );
  }
}
