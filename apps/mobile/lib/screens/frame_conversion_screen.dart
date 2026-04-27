// lib/screens/frame_conversion_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import 'result_screen.dart';
import 'frame_selection_screen.dart'; // ControlButton, FrameOptionCard 재사용을 위해

class FrameConversionScreen extends StatefulWidget {
  const FrameConversionScreen({super.key});

  @override
  State<FrameConversionScreen> createState() => _FrameConversionScreenState();
}

class _FrameConversionScreenState extends State<FrameConversionScreen> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedPhotos = [];
  FrameType _selectedFrame = FrameType.classic;

  // 💡 [수정 포인트]: 카메라가 아닌 기기 갤러리에서 여러 장의 사진을 불러오는 로직
  Future<void> _pickPhotosFromGallery() async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage();
      if (photos.isNotEmpty) {
        setState(() {
          _selectedPhotos.addAll(photos);
          // 선택된 프레임의 최대 요구 장수를 넘어가면 자르기
          if (_selectedPhotos.length > _selectedFrame.photoCount) {
            _selectedPhotos = _selectedPhotos.sublist(0, _selectedFrame.photoCount);
          }
        });
      }
    } catch (e) {
      debugPrint("갤러리 접근 오류: $e");
    }
  }

  // 💡 [수정 포인트]: 선택한 프레임 레이아웃에 맞춰 빈 칸 또는 불러온 사진을 보여주는 미리보기
  Widget _buildConversionPreview() {
    return Container(
      width: 180,
      height: 250,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _selectedFrame == FrameType.trio ? Colors.pink[100] : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
      ),
      child: _selectedFrame == FrameType.square
          ? GridView.builder( // 2x2 레이아웃
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 5, mainAxisSpacing: 5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => _buildPreviewBox(index),
            )
          : Column( // 세로형 (4x1, 3x1, 1x1) 레이아웃
              children: List.generate(
                _selectedFrame.photoCount,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    child: _buildPreviewBox(index),
                  ),
                ),
              ),
            ),
    );
  }

  // 💡 미리보기 칸 (사진이 채워졌으면 사진을, 아니면 아이콘을 보여줌)
  Widget _buildPreviewBox(int index) {
    if (index < _selectedPhotos.length) {
      return Image.file(File(_selectedPhotos[index].path), fit: BoxFit.cover);
    }
    return Container(
      color: Colors.grey.shade200,
      child: const Center(child: Icon(Icons.image, color: Colors.grey, size: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar 영역
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
                  const Text('pho\'s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            // 사진 선택 헤더
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Choose Photos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: _pickPhotosFromGallery, // 💡 갤러리 열기
                    child: const Text('Select Photo', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // 선택된 사진들 썸네일 가로 리스트
            if (_selectedPhotos.isNotEmpty)
              Container(
                height: 80,
                padding: const EdgeInsets.only(left: 20),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedPhotos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_selectedPhotos[index].path), width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            if (_selectedPhotos.isEmpty)
              const SizedBox(height: 80, child: Center(child: Text('사진을 선택해주세요', style: TextStyle(color: Colors.grey)))),

            const Spacer(),
            
            // 중앙 프레임 미리보기
            _buildConversionPreview(),
            
            const Spacer(),

            // 프레임 선택 영역
            const Text('Choose Frame', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: FrameType.values.map((frame) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7.5),
                  child: FrameOptionCard(
                    frameType: frame,
                    isSelected: _selectedFrame == frame,
                    onTap: () {
                      setState(() {
                        _selectedFrame = frame;
                        // 만약 바뀐 프레임보다 선택한 사진이 많다면 잘라내기
                        if (_selectedPhotos.length > _selectedFrame.photoCount) {
                          _selectedPhotos = _selectedPhotos.sublist(0, _selectedFrame.photoCount);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // 💡 [수정 포인트]: 선택 완료 후 기존 ResultScreen으로 이동하여 그대로 저장 기능 재활용
            ElevatedButton.icon(
              onPressed: _selectedPhotos.length == _selectedFrame.photoCount 
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // 이전에 만들어둔 결과 화면을 그대로 재사용합니다!
                        builder: (context) => ResultScreen(selectedFrame: _selectedFrame, photos: _selectedPhotos),
                      ),
                    );
                  }
                : null, // 요구 장수를 다 채우지 않으면 버튼 비활성화
              icon: const Icon(Icons.check),
              label: const Text('결과 만들기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}