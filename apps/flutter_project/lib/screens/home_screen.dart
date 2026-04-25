import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'frame_selection_screen.dart'; // 이동할 화면 import
import '../core/constants.dart'; // 상수 임포트
import 'package:shared_preferences/shared_preferences.dart';
import 'gallery_screen.dart'; // 💡 SavedPhoto 클래스 사용을 위해 임포트

// ----------------------------------------------------
// 1. 기존 홈 화면 클래스
// ----------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 헤더 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.black54),
                Text(
                  'pho\'s', 
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)
                ),
                const SizedBox(width: 24),
              ],
            ),
            const SizedBox(height: 40),
            
            // 타이틀 영역
            const Text('CAPTURE THE MOMENT', style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.grey)),
            const SizedBox(height: 10),
            const Text('오늘의 조각을\n기록해보세요', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.3)),
            const SizedBox(height: 30),
            
            // 촬영 버튼 영역
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FrameSelectionScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                label: const Text('Take a Shot', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            
            // 최신 스트립 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Latest Strips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    // 💡 나중에 네비게이션 바의 갤러리 탭으로 이동하도록 연결하면 좋습니다.
                  }, 
                  child: const Text('VIEW ALL', style: TextStyle(color: Color(0xFF9D72FF)))
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // 💡 [수정 포인트 1]: 하드코딩된 리스트 대신 아래에서 만든 동적 리스트 위젯을 삽입!
            const LatestStripsList(),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
} // ⬅️ HomeScreen 클래스 종료


// ====================================================
// 💡 [수정 포인트 2]: 파일 맨 아래에 추가되는 독립된 위젯 (최신 사진 불러오기 담당)
// ====================================================
class LatestStripsList extends StatefulWidget {
  const LatestStripsList({super.key});

  @override
  State<LatestStripsList> createState() => _LatestStripsListState();
}

class _LatestStripsListState extends State<LatestStripsList> {
  List<SavedPhoto> _latestPhotos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLatestPhotos();
  }

  // 화면에 다시 포커스가 올 때마다 새로고침
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLatestPhotos();
  }

  Future<void> _loadLatestPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];

    List<SavedPhoto> loadedPhotos = [];
    for (String jsonStr in savedStrings) {
      Map<String, dynamic> data = jsonDecode(jsonStr);
      FrameType type = FrameType.values.firstWhere(
        (e) => e.name == data['frameType'], 
        orElse: () => FrameType.classic
      );
      
      loadedPhotos.add(SavedPhoto(
        path: data['path'],
        frameType: type,
        title: data['title'],
        tag: data['tag'],
      ));
    }

    setState(() {
      // 💡 가장 최근에 찍은 사진이 맨 앞으로 오게 뒤집고, 5장만 가져옵니다.
      _latestPhotos = loadedPhotos.reversed.take(5).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()));
    }

    if (_latestPhotos.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: const Text('아직 촬영된 사진이 없습니다.\n첫 조각을 기록해보세요!', 
          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 270, // 카드가 잘리지 않도록 높이 확보
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _latestPhotos.length,
        itemBuilder: (context, index) {
          final photo = _latestPhotos[index];
          
          // 💡 파일의 생성 날짜(수정 날짜)를 가져와서 텍스트로 변환 (예: 2024.05.14)
          final fileStat = File(photo.path).statSync();
          final dateStr = "${fileStat.modified.year}.${fileStat.modified.month.toString().padLeft(2, '0')}.${fileStat.modified.day.toString().padLeft(2, '0')}";

          // 질문자님이 만드셨던 기존 디자인(_buildStripCard)을 그대로 가져와 실제 데이터를 입혔습니다!
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16, bottom: 10), // 그림자 짤림 방지 bottom margin
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카드 상단 이미지 영역
                Container(
                  height: 200, 
                  decoration: const BoxDecoration(
                    color: Colors.black12, 
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.file(
                      File(photo.path), 
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                    ),
                  ),
                ),
                // 카드 하단 텍스트 영역
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(photo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}