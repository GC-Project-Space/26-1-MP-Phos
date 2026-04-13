import 'package:flutter/material.dart';
import 'result_screen.dart'; // (파일을 분리했을 경우 유지, 안 했으면 제거)

class FrameSelectionScreen extends StatefulWidget {
  const FrameSelectionScreen({super.key});

  @override
  State<FrameSelectionScreen> createState() => _FrameSelectionScreenState();
}

class _FrameSelectionScreenState extends State<FrameSelectionScreen> {
  // 1. 현재 선택된 프레임을 저장하는 변수 추가 (기본값: CLASSIC)
  String _selectedFrame = 'CLASSIC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
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
                      const Text('pho\'s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9D72FF))),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Spacer(),
                // 2. 프레임 선택 UI (선택된 상태 비교 추가)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildFrameOption('CLASSIC', height: 120),
                    const SizedBox(width: 15),
                    _buildFrameOption('SQUARE', height: 100),
                    const SizedBox(width: 15),
                    _buildFrameOption('TRIO', height: 110, color: Colors.pink[100]),
                    const SizedBox(width: 15),
                    _buildFrameOption('SOLO', height: 90),
                  ],
                ),
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ResultScreen()),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9D72FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF9D72FF).withOpacity(0.3), width: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
            Positioned(
              right: 20,
              top: 80,
              child: Column(
                children: [
                  _buildControlButton(Icons.flash_off),
                  const SizedBox(height: 15),
                  _buildControlButton(Icons.timer),
                  const SizedBox(height: 15),
                  _buildControlButton(Icons.cameraswitch),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  // 3. 터치 이벤트를 받기 위해 GestureDetector 추가
  Widget _buildFrameOption(String label, {required double height, Color? color}) {
    // 현재 위젯의 라벨이 선택된 상태인지 확인
    bool isSelected = _selectedFrame == label; 

    return GestureDetector(
      onTap: () {
        // 탭 했을 때 _selectedFrame 값을 변경하고 화면을 다시 그림
        setState(() {
          _selectedFrame = label;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: height,
            decoration: BoxDecoration(
              color: color ?? Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF9D72FF) : Colors.transparent, 
                width: 2
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 10, 
              fontWeight: FontWeight.bold, 
              color: isSelected ? const Color(0xFF9D72FF) : Colors.grey
            ),
          ),
        ],
      ),
    );
  }
}