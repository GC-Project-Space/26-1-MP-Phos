import 'package:flutter/material.dart';

/// 프레임 레이아웃 종류 정의
enum FrameType {
  grid2x2,  // 2x2 격자 형태 (총 4장)
  strip1x4, // 1x4 세로 스트립 (총 4장)
  strip1x3, // 1x3 세로 스트립 (총 3장)
}

/// 커스텀 프레임 디자인 모델
class FrameDesign {
  final String id;
  final String name;
  final BoxDecoration decoration; // 단색, 그라디언트, 배경 이미지 등 설정
  final Color textColor;          // 하단 텍스트/로고 색상
  final String brandText;         // 하단 브랜드 텍스트

  FrameDesign({
    required this.id,
    required this.name,
    required this.decoration,
    required this.textColor,
    this.brandText = "L I F E  4  C U T S",
  });
}