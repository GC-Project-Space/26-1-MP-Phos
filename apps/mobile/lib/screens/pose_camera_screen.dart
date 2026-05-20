import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:async';

class PoseCameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const PoseCameraScreen({super.key, required this.cameras});

  @override
  State<PoseCameraScreen> createState() => _PoseCameraScreenState();
}

class _PoseCameraScreenState extends State<PoseCameraScreen> {
  late CameraController _cameraController;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: false,
      enableLandmarks: false,
      performanceMode: FaceDetectorMode.fast, // 실시간 처리를 위해 fast 모드 사용
    ),
  );

  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  
  // 포즈 추천 UI 상태 관리 변수
  int _detectedFaceCount = 0;
  bool _showPoseImage = false;
  String _currentPoseImagePath = '';
  Timer? _hideImageTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // 전면 카메라를 기본으로 사용 (인생네컷 형태)
    final frontCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController.initialize();
    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    // 실시간 이미지 스트림 분석 시작
    _cameraController.startImageStream((CameraImage image) {
      _processCameraImage(image);
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing) return; // 이미 처리 중이면 스킵 (과부하 방지)
    _isProcessing = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final List<Face> faces = await _faceDetector.processImage(inputImage);
      final int currentFaceCount = faces.length;

      // 화면에 사람이 있고, 이전 인원수와 달라졌을 때만 포즈 추천 실행
      if (currentFaceCount > 0 && currentFaceCount != _detectedFaceCount) {
        _detectedFaceCount = currentFaceCount;
        _triggerPoseRecommendation(currentFaceCount);
      } else if (currentFaceCount == 0) {
        _detectedFaceCount = 0;
      }
    } catch (e) {
      debugPrint("얼굴 인식 오류: $e");
    } finally {
      _isProcessing = false;
    }
  }

  void _triggerPoseRecommendation(int count) {
    // 최대 4인까지만 준비된 이미지가 있다고 가정
    int clampedCount = count > 4 ? 4 : count; 
    
    setState(() {
      _currentPoseImagePath = 'assets/poses/${clampedCount}_person.png';
      _showPoseImage = true;
    });

    // 기존 타이머가 있다면 취소하고 새로 시작
    _hideImageTimer?.cancel();
    
    // 3초 뒤에 사진이 스르륵 사라지도록 타이머 설정
    _hideImageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showPoseImage = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cameraController.stopImageStream();
    _cameraController.dispose();
    _faceDetector.close();
    _hideImageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF9D72FF))),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 카메라 프리뷰 (배경)
          CameraPreview(_cameraController),

          // 2. 인원수별 포즈 추천 이미지 오버레이 (띄웠다가 사라짐)
          AnimatedOpacity(
            opacity: _showPoseImage ? 1.0 : 0.0, // 서서히 나타나고 사라지는 애니메이션 효과
            duration: const Duration(milliseconds: 500),
            child: _showPoseImage
                ? Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        // 로컬에 저장된 에셋 이미지를 불러옵니다.
                        child: Image.asset(
                          _currentPoseImagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // 3. 현재 인식된 인원수 표시 (디버깅 및 사용자 안내용)
          Positioned(
            top: 50,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '인식된 인원: $_detectedFaceCount명',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          
          // 뒤로가기 버튼
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- 카메라 스트림을 ML Kit InputImage로 변환하는 유틸리티 함수 ---
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );
    
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = sensorOrientation;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.isEmpty) return null;

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }
}