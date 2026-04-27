import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui; // 💡 위젯 캡처를 위해 필요

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 💡 RenderRepaintBoundary를 위해 필요
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../core/constants.dart';

import 'dart:convert'; // JSON 변환용
import 'package:shared_preferences/shared_preferences.dart';

class ResultScreen extends StatefulWidget {
  final FrameType selectedFrame;
  final List<XFile> photos;

  const ResultScreen({super.key, required this.selectedFrame, required this.photos});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // 💡 캡처할 영역을 특정하기 위한 GlobalKey 생성
  final GlobalKey _globalKey = GlobalKey();

  /// 💡 [저장 기능] 위젯을 이미지로 변환하여 저장하는 핵심 함수
  Future<void> _saveResultImage() async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) await Gal.requestAccess();

      // 1. 위젯 캡처 및 이미지 파일 생성
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      // 💡 파일명에 프레임 이름을 살짝 적어두는 것도 좋은 팁입니다.
      String fileName = 'phos_${widget.selectedFrame.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File('${tempDir.path}/$fileName').create();
      await file.writeAsBytes(pngBytes);

      // 2. 갤러리에 저장
      await Gal.putImage(file.path);

      // ----------------------------------------------------
      // 💡 3. [핵심] 앱 내부 장부에 사진 정보(메타데이터) 기록하기
      // ----------------------------------------------------
      final prefs = await SharedPreferences.getInstance();
      
      // 기존에 저장된 사진 목록(문자열 리스트)을 불러옴
      List<String> savedPhotos = prefs.getStringList('phos_gallery_data') ?? [];
      
      // 방금 저장한 사진의 정보를 Map(사전) 형태로 생성
      Map<String, dynamic> newPhotoData = {
        'path': file.path,                     // 사진이 임시 저장된 파일 경로 (갤러리용으로 띄울 때 사용)
        'frameType': widget.selectedFrame.name, // "classic", "square" 등 Enum의 이름
        'title': 'Untitled',                   // 초기 이름 (나중에 수정 가능하도록)
        'tag': 'my_moment',                    // 초기 태그
        'date': DateTime.now().toIso8601String()
      };

      // Map을 JSON 문자열로 변환하여 리스트에 추가하고 다시 장부에 저장
      savedPhotos.add(jsonEncode(newPhotoData));
      await prefs.setStringList('phos_gallery_data', savedPhotos);
      // ----------------------------------------------------

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('갤러리와 장부에 성공적으로 저장되었습니다! 🎉')),
        );
      }
    } catch (e) {
      debugPrint("저장 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Result', style: TextStyle(color: Colors.black)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 💡 [수정 포인트]: 캡처하고 싶은 위젯을 RepaintBoundary로 감싸고 Key를 부여함
              RepaintBoundary(
                key: _globalKey,
                child: _buildRenderedStrip(),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _saveResultImage, // 💡 저장 함수 연결
                    icon: const Icon(Icons.download),
                    label: const Text('Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  /// (기존 _buildRenderedStrip 코드는 동일)
  Widget _buildRenderedStrip() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: widget.selectedFrame == FrameType.trio ? Colors.pink[100] : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.selectedFrame == FrameType.square)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.photos.length,
              itemBuilder: (context, index) => Image.file(File(widget.photos[index].path), fit: BoxFit.cover),
            )
          else
            Column(
              children: widget.photos.map((photo) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AspectRatio(
                  aspectRatio: 3 / 2,
                  child: Image.file(File(photo.path), fit: BoxFit.cover),
                ),
              )).toList(),
            ),
          const SizedBox(height: 10),
          const Text('pho\'s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          Text(DateTime.now().toString().substring(0, 10), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}