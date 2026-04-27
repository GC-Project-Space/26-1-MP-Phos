import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9D72FF);
  static const Color background = Color(0xFFFAF9F6);
  static const Color textMain = Colors.black87;
  static const Color textSub = Colors.grey;
}

enum FrameType {
  // 사진 컷 수(photoCount)와 가로/세로 비율 구분 속성 추가
  classic('CLASSIC', 120.0, 4), // 4x1 세로 네컷
  square('SQUARE', 100.0, 4),   // 2x2 정사각형
  trio('TRIO', 110.0, 3),       // 3x1 세로 세컷
  solo('SOLO', 90.0, 1);        // 1컷 단독

  final String label;
  final double defaultHeight;
  final int photoCount;

  const FrameType(this.label, this.defaultHeight, this.photoCount);
}