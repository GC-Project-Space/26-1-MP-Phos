import 'dart:io';
import 'package:flutter/material.dart';
import '../models/frame_design.dart';
import '../widgets/custom_four_cut_frame.dart';
import '../services/frame_capture_service.dart';
import 'camera_booth_screen.dart';

class LifeFourCutsCreatorScreen extends StatefulWidget {
  const LifeFourCutsCreatorScreen({Key? key}) : super(key: key);

  @override
  State<LifeFourCutsCreatorScreen> createState() => _LifeFourCutsCreatorScreenState();
}

class _LifeFourCutsCreatorScreenState extends State<LifeFourCutsCreatorScreen> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  FrameType _selectedType = FrameType.grid2x2;
  late FrameDesign _selectedDesign;
  List<File?> _capturedPhotos = [null, null, null, null];

  final List<FrameDesign> _customFrameTemplates = [
    FrameDesign(
      id: "midnight_black",
      name: "미드나잇 블랙",
      textColor: Colors.white,
      decoration: const BoxDecoration(color: Colors.black),
    ),
    FrameDesign(
      id: "soft_pink",
      name: "파스텔 핑크",
      textColor: Colors.black87,
      decoration: const BoxDecoration(color: Color(0xFFFEE2E2)),
    ),
    FrameDesign(
      id: "gradient_aurora",
      name: "오로라 그라데이션",
      textColor: Colors.blueGrey,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFff9a9e), Color(0xFFfecfef), Color(0xFFa1c4fd)],
        ),
      ),
    ),
    FrameDesign(
      id: "wood_pattern",
      name: "빈티지 체크",
      textColor: Colors.brown,
      decoration: const BoxDecoration(
        gradient: SweepGradient(
          colors: [Color(0xFFE5D9C4), Color(0xFFC3B091), Color(0xFFE5D9C4)],
        ),
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDesign = _customFrameTemplates.first;
  }

  void _updateLayoutType(FrameType newType) {
    setState(() {
      _selectedType = newType;
      _capturedPhotos = List<File?>.filled(
        newType == FrameType.strip1x3 ? 3 : 4,
        null,
      );
    });
  }

  Future<void> _launchCameraBooth() async {
    final int requiredCount = _selectedType == FrameType.strip1x3 ? 3 : 4;

    final List<File>? result = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (context) => CameraBoothScreen(requiredPhotos: requiredCount),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _capturedPhotos = List<File?>.from(result);
      });
    }
  }

  Future<void> _saveFinalComposite() async {
    if (_capturedPhotos.any((element) => element == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아직 촬영하지 않은 빈 사진 슬롯이 존재합니다!')),
      );
      return;
    }

    final File? capturedFile = await FrameCaptureService.saveFrameAsImage(_repaintBoundaryKey);
    if (capturedFile != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('🎉 합성 완료'),
          content: Text('커스텀 프레임이 입혀진 고해상도 이미지가 생성되었습니다!\n\n저장 경로: ${capturedFile.path}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('인앱 인생네컷 프레임 스튜디오'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                  child: RepaintBoundary(
                    key: _repaintBoundaryKey,
                    child: CustomFourCutFrame(
                      images: _capturedPhotos,
                      frameType: _selectedType,
                      design: _selectedDesign,
                      onPhotoTap: (index) => _launchCameraBooth(),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '1. 레이아웃 비율 선택',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    ElevatedButton.icon(
                      onPressed: _launchCameraBooth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.camera_front_sharp, size: 18),
                      label: const Text('부스 촬영하기'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLayoutSelectButton(FrameType.grid2x2, '2 x 2 격자'),
                    _buildLayoutSelectButton(FrameType.strip1x4, '1 x 4 세로'),
                    _buildLayoutSelectButton(FrameType.strip1x3, '1 x 3 세로'),
                  ],
                ),
                const Divider(height: 32, thickness: 1),
                const Text(
                  '2. 자체 제작 테마 프레임 디자인',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _customFrameTemplates.length,
                    itemBuilder: (context, index) {
                      final template = _customFrameTemplates[index];
                      final isSelected = template.id == _selectedDesign.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDesign = template;
                            });
                          },
                          child: Chip(
                            label: Text(
                              template.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            backgroundColor: isSelected ? Colors.indigoAccent : Colors.grey[200],
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveFinalComposite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      '완성된 프레임 이미지 저장하기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutSelectButton(FrameType type, String label) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton(
          onPressed: () => _updateLayoutType(type),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? Colors.indigoAccent.withOpacity(0.08) : Colors.transparent,
            side: BorderSide(
              color: isSelected ? Colors.indigoAccent : Colors.grey[300]!,
              width: isSelected ? 2.0 : 1.0,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.indigoAccent : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}