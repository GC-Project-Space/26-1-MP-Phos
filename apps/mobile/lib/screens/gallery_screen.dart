// lib/screens/gallery_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import 'frame_conversion_screen.dart';

// 💡 이제 더미가 아닌 진짜 데이터를 담을 클래스입니다.
class SavedPhoto {
  final String path;
  final FrameType frameType;
  final String title;
  final String tag;

  SavedPhoto({required this.path, required this.frameType, required this.title, required this.tag});
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // 💡 [수정 포인트]: 상태 관리를 위한 변수들
  FrameType _selectedFilter = FrameType.classic; // 기본 필터: 4x1 (CLASSIC)
  bool _isSearchActive = false; // 검색창 활성화 여부
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 💡 장부에서 불러온 진짜 사진 목록을 담을 리스트
  List<SavedPhoto> _myGallery = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPhotos(); // 화면이 켜질 때 장부를 읽어옵니다.
  }

  // 💡 [핵심] SharedPreferences 장부에서 데이터 읽어오기
  Future<void> _loadSavedPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];

    List<SavedPhoto> loadedPhotos = [];
    for (String jsonStr in savedStrings) {
      Map<String, dynamic> data = jsonDecode(jsonStr);
      
      // 문자열로 저장된 프레임 종류를 다시 Enum으로 변환
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
      // 최신 사진이 위로 오게 뒤집어서 저장
      _myGallery = loadedPhotos.reversed.toList();
      _isLoading = false;
    });
  }

  // 장부에서 이름을 찾아 수정하는 핵심  함수
  Future<void> _updatePhotoTitle(String targetPath, String newTitle) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];

    for (int i = 0; i < savedStrings.length; i++) {
      Map<String, dynamic> data = jsonDecode(savedStrings[i]);
      // 경로가 일치하는 사진을 찾아 이름 변경
      if (data['path'] == targetPath) {
        data['title'] = newTitle;
        savedStrings[i] = jsonEncode(data); // 덮어쓰기
        break;
      }
    }
    
    await prefs.setStringList('phos_gallery_data', savedStrings);
    _loadSavedPhotos(); // 이름 변경 후 화면 즉시 새로고침
  }

  // 💡사용자에게 새 이름을 입력받는 팝업창
  void _showEditTitleDialog(SavedPhoto photo) {
    TextEditingController editController = TextEditingController(text: photo.title);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('사진 이름 수정'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "새로운 이름을 입력하세요"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _updatePhotoTitle(photo.path, editController.text.trim());
                }
                Navigator.pop(context); // 저장 후 팝업 닫기
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('저장', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String _getFrameLabel(FrameType type) {
    switch (type) {
      case FrameType.classic: return '4x1';
      case FrameType.square: return '2x2';
      case FrameType.trio: return '3x1';
      case FrameType.solo: return '1x1';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 [수정 포인트]: 선택된 필터와 검색어에 맞춰 리스트 걸러내기
    final filteredGallery = _myGallery.where((photo) {
      final matchesFilter = photo.frameType == _selectedFilter;
      final matchesSearch = photo.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            photo.tag.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 AppBar 영역
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.black54),
                const Text('pho\'s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                // 💡 [수정 포인트]: 돋보기 버튼 클릭 시 검색창 토글
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                  },
                ),
              ],
            ),
          ),
          
          // 💡 [수정 포인트]: 검색창 UI (활성화 되었을 때만 보임)
          if (_isSearchActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 15),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '사진 이름이나 태그로 검색...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

          // Your Gallery & 변환 버튼 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Gallery', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                // 💡 [수정 포인트]: 프레임 변환 화면으로 넘어가는 버튼
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FrameConversionScreen()),
                    );
                  },
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('프레임 변환하기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 💡 [수정 포인트]: 필터 칩 영역 (Enum values 기반으로 자동 생성)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: FrameType.values.map((frame) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = frame),
                    child: _buildFilterChip(_getFrameLabel(frame), _selectedFilter == frame),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // 갤러리 그리드 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredGallery.isEmpty
                    ? const Center(child: Text('해당하는 사진이 없습니다.', style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredGallery.length,
                        itemBuilder: (context, index) {
                          final photo = filteredGallery[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // 1. 사진 배경
                                Image.file(
                                  File(photo.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                                ),
                                
                                // 2. 이름/태그 오버레이
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${photo.title}\n#${photo.tag}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                
                                // 💡 [핵심] 바로 이 부분이 함수를 사용하는 곳입니다!
                                Positioned(
                                  top: 5, right: 5,
                                  child: GestureDetector(
                                    // 연필 아이콘을 탭하면 에러가 나던 그 함수가 실행됩니다!
                                    onTap: () => _showEditTitleDialog(photo), 
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                    ),
                                  ),
                                )
                                // --------------------------------------------------
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
      ),
    );
  }
}