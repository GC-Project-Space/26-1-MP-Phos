import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 💡 카메라 패키지 임포트
import '../core/constants.dart';
import 'result_screen.dart';

class FrameSelectionScreen extends StatefulWidget {
  const FrameSelectionScreen({super.key});

  @override
  State<FrameSelectionScreen> createState() => _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends State<FrameSelectionScreen> {
  FrameType _selectedFrame = FrameType.classic;
  final ImagePicker _picker = ImagePicker();
  bool _isShooting = false; // 촬영 진행 중 로딩 상태 표시용

  // 💡 [수정 포인트]: 실제 카메라를 연속으로 띄워 사진을 수집하는 로직
  Future<void> _takePictures() async {
    setState(() => _isShooting = true);
    List<XFile> takenPhotos = [];

    int targetCount = _selectedFrame.photoCount;

    try {
      for (int i = 0; i < targetCount; i++) {
        // 실제 카메라 실행 (기기 테스트 시 작동)
        final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
        
        if (photo != null) {
          takenPhotos.add(photo);
        } else {
          // 사용자가 중간에 카메라를 취소하면 촬영 중단
          break; 
        }
      }

      // 목표한 사진 매수를 모두 채웠을 때만 결과 화면으로 이동
      if (takenPhotos.length == targetCount && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              selectedFrame: _selectedFrame,
              photos: takenPhotos, // 💡 촬영한 사진 리스트 전달
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("카메라 오류: $e");
    } finally {
      if (mounted) setState(() => _isShooting = false);
    }
  }

  // 💡 [수정 포인트]: 프레임 모양을 미리 보여주는 뷰어 위젯
  Widget _buildFramePreview() {
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
          // 2x2 정사각형 레이아웃 미리보기
          ? GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => Container(color: Colors.grey.shade300),
            )
          // 그 외 세로형 (4x1, 3x1, 1x1) 레이아웃 미리보기
          : Column(
              children: List.generate(
                _selectedFrame.photoCount,
                (index) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 5),
                    color: Colors.grey.shade300,
                  ),
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text('pho\'s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                
                // 💡 추가된 미리보기 영역
                const SizedBox(height: 20),
                _buildFramePreview(),
                
                const Spacer(),
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
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 50),
                
                // 촬영 버튼
                GestureDetector(
                  onTap: _isShooting ? null : _takePictures, // 💡 촬영 로직 연결
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 8),
                    ),
                    child: _isShooting 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ... (FrameOptionCard 위젯은 기존과 동일) ...
class FrameOptionCard extends StatelessWidget {
  final FrameType frameType;
  final bool isSelected;
  final VoidCallback onTap;

  const FrameOptionCard({super.key, required this.frameType, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final boxColor = frameType == FrameType.trio ? Colors.pink[100] : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: frameType.defaultHeight,
            decoration: BoxDecoration(
              color: boxColor,
              border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
            ),
          ),
          const SizedBox(height: 10),
          Text(frameType.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.textSub)),
        ],
      ),
    );
  }
}