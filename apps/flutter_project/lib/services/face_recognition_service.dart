import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class FaceRecognitionService {
  // 싱글턴 패턴: 앱 전체에서 이 서비스의 인스턴스는 단 하나만 존재하도록 합니다.
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  Interpreter? _interpreter; // TFLite 모델을 실행할 인터프리터
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate, // 정확도 우선
    ),
  );

  /// [핵심] 앱 시작 시 TFLite 모델을 메모리에 로드하는 함수
  Future<void> initialize() async {
    try {
      // assets에서 모델 파일을 불러와 인터프리터를 생성합니다.
      _interpreter = await Interpreter.fromAsset('assets/ml/MobileFaceNet.tflite');
      print('✅ 모델 로딩 성공');
    } catch (e) {
      print('🚨 모델 로딩 실패: $e');
    }
  }

  /// [핵심] 이미지 파일(XFile)을 받아 얼굴 특징(Embedding) 리스트를 추출하는 함수
  Future<List<List<double>>> getEmbeddings(XFile imageFile) async {
    if (_interpreter == null) {
      print('🚨 모델이 초기화되지 않았습니다. initialize()를 먼저 호출하세요.');
      return [];
    }

    try {
      // 1. 이미지를 ML Kit이 인식할 수 있는 형태로 변환
      final inputImage = InputImage.fromFilePath(imageFile.path);
      
      // 2. 이미지에서 얼굴 목록 감지
      final List<Face> faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        print('⚠️ 감지된 얼굴이 없습니다.');
        return [];
      }

      // 3. 원본 이미지를 image 패키지 형식으로 디코딩
      final bytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(bytes);
      if (originalImage == null) return [];
      
      List<List<double>> allEmbeddings = [];

      // 4. 감지된 각 얼굴에 대해 특징 추출 수행
      for (Face face in faces) {
        // 얼굴 영역의 좌표를 정수형으로 변환
        final rect = face.boundingBox;
        final int x = rect.left.toInt();
        final int y = rect.top.toInt();
        final int w = rect.width.toInt();
        final int h = rect.height.toInt();

        // 5. 원본 이미지에서 얼굴 부분만 잘라내기 (Crop)
        final img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);

        // 6. 모델의 입력 크기(112x112)에 맞게 리사이즈
        final img.Image resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

        // 7. 이미지를 모델이 요구하는 형식(List<double>)으로 변환 및 정규화
        final Float32List preprocessedImage = _preprocessImage(resizedFace);
        
        // 8. 모델 실행
        // 입력 형태: [1, 112, 112, 3], 출력 형태: [1, 512]
        final input = preprocessedImage.reshape([1, 112, 112, 3]);
        final output = List.filled(1 * 512, 0.0).reshape([1, 512]);

        _interpreter!.run(input, output);
        
        // 9. 결과(Embedding)를 리스트에 추가
        allEmbeddings.add(output[0] as List<double>);
      }

      return allEmbeddings;

    } catch (e) {
      print('🚨 얼굴 특징 추출 중 오류 발생: $e');
      return [];
    }
  }

  /// 이미지를 TFLite 모델의 입력 형식에 맞게 전처리하는 내부 함수
  Float32List _preprocessImage(img.Image image) {
    final buffer = Float32List(1 * 112 * 112 * 3);
    int bufferIndex = 0;
    
    // 이미지를 픽셀 단위로 순회하며 정규화 수행
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // 픽셀 값을 [-1, 1] 범위로 정규화합니다. (model specific)
        buffer[bufferIndex++] = (pixel.r - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.g - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return buffer;
  }

  // 서비스 종료 시 리소스 해제
  void dispose() {
    _faceDetector.close();
    if (_interpreter != null) {
      _interpreter!.close();
    }
  }
}