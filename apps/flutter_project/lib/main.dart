import 'package:flutter/material.dart';
import 'screens/main_layout.dart'; // ⬅️ 이 줄을 추가해주세요.
import 'services/face_recognition_service.dart'; // ❗️ 이 줄을 추가하거나 확인하세요.
// void main() {  // ⬅️ 기존 코드
//   runApp(const PhotoBoothApp());
// }

// ✅ 수정된 코드
Future<void> main() async {
  // Flutter 엔진과 위젯 바인딩이 준비되었는지 확인합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 앱이 시작될 때 얼굴 인식 모델을 미리 로딩합니다.
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