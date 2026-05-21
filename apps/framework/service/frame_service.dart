import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class FrameCaptureService {
  static Future<File?> saveFrameAsImage(GlobalKey repaintKey) async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 고해상도 저장을 위해 pixelRatio: 3.0 유지
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final directory = await getTemporaryDirectory();
      final String filePath = '${directory.path}/life4cuts_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File(filePath);

      await file.writeAsBytes(pngBytes);
      return file;
    } catch (e) {
      debugPrint('프레임 캡처 이미지 생성 오류: $e');
      return null;
    }
  }
}