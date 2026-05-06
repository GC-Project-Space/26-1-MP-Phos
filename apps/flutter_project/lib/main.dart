import 'package:flutter/material.dart';
import 'screens/main_layout.dart'; // ⬅️ 이 줄을 추가해주세요.
import 'services/face_recognition_service.dart'; // 서비스 파일 import
Future<void> main() async {
  // Flutter 프레임워크가 앱을 실행할 준비가 되도록 보장합니다.
  // main 함수가 async인 경우 반드시 필요합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // runApp을 호출하기 전에 서비스 초기화를 완료합니다.
  await FaceRecognitionService().initialize();

  runApp(const PhotoBoothApp());
}

class PhotoBoothApp extends StatelessWidget {
  const PhotoBoothApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pho\'s App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        primaryColor: const Color(0xFF9D72FF),
        fontFamily: 'Roboto',
      ),
      home: const MainLayout(), // 이 위젯을 사용하기 위해 import가 필요합니다.
      debugShowCheckedModeBanner: false,
    );
  }
}