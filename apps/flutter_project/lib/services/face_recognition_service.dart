import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
// import 'package:flutter_project/core/constants.dart'; // FrameType은 gallery_screen.dart에만 있으면 됩니다.

// FrameType enum을 정의하거나 import 해야 합니다.
// 예시로 아래와 같이 정의합니다.
enum FrameType { classic }

class FaceRecognitionService {
  // 싱글턴 패턴: 앱 전체에서 이 서비스의 인스턴스는 단 하나만 존재하도록 합니다.
  static final FaceRecognitionService _instance = FaceRecognitionService._internal();
  factory FaceRecognitionService() => _instance;
  FaceRecognitionService._internal();

  Interpreter? _interpreter; // TFLite 모델을 실행할 인터프리터
  final FaceDetector _faceDetector = FaceDetector( // ML Kit 얼굴 감지기 초기화
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate, // 정확도 우선
    ),
  );

  // 모델 파일 경로 및 입력/출력 크기 상수화
  static const String _modelPath = 'assets/ml/facenet_512.tflite'; // <-- 정확한 모델 경로로 수정
  static const int _inputImageWidth = 160; // FaceNet 입력 이미지 너비
  static const int _inputImageHeight = 160; // FaceNet 입력 이미지 높이
  static const int _outputEmbeddingSize = 512; // FaceNet 출력 임베딩 크기 (512차원)

  /// [핵심] 앱 시작 시 TFLite 모델을 메모리에 로드하는 함수
  Future<void> initialize() async {
    try {
      // assets에서 모델 파일을 불러와 인터프리터를 생성합니다.
      _interpreter = await Interpreter.fromAsset(_modelPath);
      print('✅ 모델 로딩 성공: $_modelPath');
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
      img.Image? originalImage = img.decodeImage(bytes); // final 제거 및 타입 명시
      if (originalImage == null) return [];

      // EXIF 정보에 따라 이미지 방향을 보정합니다.
      // ML Kit은 방향을 자동으로 감지하지만, 'image' 패키지는 그렇지 않아
      // 얼굴 좌표가 어긋나는 문제를 방지하기 위함입니다.
      originalImage = img.bakeOrientation(originalImage);

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

        // 모델의 새로운 입력 크기(_inputImageWidth, _inputImageHeight)에 맞게 리사이즈
        final img.Image resizedFace = img.copyResize(croppedFace, width: _inputImageWidth, height: _inputImageHeight);

        // 7. 이미지를 모델이 요구하는 형식(List<double>)으로 변환 및 정규화
        final Float32List preprocessedImage = _preprocessImage(resizedFace);

        // 8. 모델 실행
        // 입력 형태: [1, _inputImageWidth, _inputImageHeight, 3]
        final input = preprocessedImage.reshape([1, _inputImageWidth, _inputImageHeight, 3]);
        // 출력 형태: [1, _outputEmbeddingSize] (512차원)
        final output = List.filled(1 * _outputEmbeddingSize, 0.0).reshape([1, _outputEmbeddingSize]);

        _interpreter!.run(input, output);

        // 9. 결과(Embedding)를 리스트에 추가
        allEmbeddings.add(List<double>.from(output[0]));
      }
      return allEmbeddings;

    } catch (e) {
      print('🚨 얼굴 특징 추출 중 오류 발생: $e');
      return [];
    }
  }

  /// 이미지를 TFLite 모델의 입력 형식에 맞게 전처리하는 내부 함수
  Float32List _preprocessImage(img.Image image) {
    // --- 디버깅을 위해 임시로 버퍼 크기 확인 ---
    // 실제 모델 입력 크기는 160x160x3 입니다.
    final int expectedSize = 1 * _inputImageWidth * _inputImageHeight * 3; // 160 * 160 * 3 = 76800
    print('Input image size: ${image.width}x${image.height}');
    print('Expected buffer size: $expectedSize');

    if (image.width != _inputImageWidth || image.height != _inputImageHeight) {
      print('⚠️ Image resize might be incorrect. Actual image size after crop: ${image.width}x${image.height}');
      // 여기서 오류를 발생시키거나, 강제로 리사이즈하도록 할 수 있습니다.
      // 일단은 다음 단계로 진행하겠습니다.
    }

    final buffer = Float32List(expectedSize); // 올바른 크기의 버퍼 생성
    int bufferIndex = 0;

    for (int y = 0; y < _inputImageHeight; y++) { // image.height 대신 _inputImageHeight 사용
      for (int x = 0; x < _inputImageWidth; x++) { // image.width 대신 _inputImageWidth 사용
        if (x < image.width && y < image.height) { // image 범위 내에서만 접근
          final pixel = image.getPixel(x, y);
          buffer[bufferIndex++] = (pixel.r - 127.5) / 127.5;
          buffer[bufferIndex++] = (pixel.g - 127.5) / 127.5;
          buffer[bufferIndex++] = (pixel.b - 127.5) / 127.5;
        } else {
          // 이미지 크기가 예상보다 작을 경우 0으로 채움 (또는 다른 처리)
          buffer[bufferIndex++] = 0.0;
          buffer[bufferIndex++] = 0.0;
          buffer[bufferIndex++] = 0.0;
        }
      }
    }
    print('Generated preprocessed image buffer length: ${buffer.length}');
    return buffer;
  }

  /// [핵심] 추출한 얼굴 특징(Embeddings)을 SharedPreferences에 저장하는 함수
  /// @param photoPath: 저장할 사진의 경로
  /// @param embeddings: 추출된 얼굴 특징 리스트
  Future<void> saveEmbeddings(String photoPath, List<List<double>> embeddings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];

      Map<String, dynamic>? photoData;
      int existingIndex = -1;

      for (int i = 0; i < savedStrings.length; i++) {
        try {
          Map<String, dynamic> data = jsonDecode(savedStrings[i]);
          if (data['path'] == photoPath) {
            photoData = data;
            existingIndex = i;
            break;
          }
    } catch (e) {
          print('SharedPreferences 데이터 파싱 오류: $e');
    }
  }

      // embeddings를 List<String>으로 변환하여 저장 (각 List<double>을 JSON 문자열로)
      final List<String> embeddingsAsStringList = embeddings.map((e) => jsonEncode(e)).toList(); // <-- 이 부분이 중요합니다.

      if (photoData == null) {
        photoData = {
          'path': photoPath,
          'frameType': FrameType.classic.name,
          'title': 'Untitled',
          'tag': 'untagged',
          'embeddings': embeddingsAsStringList, // List<String>으로 저장
        };
        savedStrings.add(jsonEncode(photoData));
      } else {
        photoData['embeddings'] = embeddingsAsStringList; // List<String>으로 업데이트
        savedStrings[existingIndex] = jsonEncode(photoData);
      }

      await prefs.setStringList('phos_gallery_data', savedStrings);
      print('✅ Embeddings saved successfully for: $photoPath');

    } catch (e) {
      print('🚨 Embeddings 저장 중 오류 발생: $e');
    }
  }

  // 서비스 종료 시 리소스 해제
  void dispose() {
    _faceDetector.close();
    if (_interpreter != null) {
      _interpreter!.close();
    }
  }
}

