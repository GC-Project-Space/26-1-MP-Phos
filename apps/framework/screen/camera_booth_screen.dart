import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraBoothScreen extends StatefulWidget {
  final int requiredPhotos;

  const CameraBoothScreen({Key? key, required this.requiredPhotos}) : super(key: key);

  @override
  State<CameraBoothScreen> createState() => _CameraBoothScreenState();
}

class _CameraBoothScreenState extends State<CameraBoothScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 1; 
  bool _isCameraInitialized = false;

  final List<File> _capturedFiles = [];
  int _currentCaptureIndex = 0;

  Timer? _timer;
  int _timerSeconds = 3;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        int frontCamIndex = _cameras.indexWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
        );
        _selectedCameraIndex = frontCamIndex != -1 ? frontCamIndex : 0;
        await _startCameraController(_cameras[_selectedCameraIndex]);
      }
    } catch (e) {
      debugPrint('카메라 장비 검색 실패: $e');
    }
  }

  Future<void> _startCameraController(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('카메라 컨트롤러 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleCamera() async {
    if (_cameras.length < 2) return;
    setState(() {
      _isCameraInitialized = false;
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;
    });
    await _startCameraController(_cameras[_selectedCameraIndex]);
  }

  void _triggerCountdown() {
    if (_isCountingDown || _currentCaptureIndex >= widget.requiredPhotos) return;

    setState(() {
      _isCountingDown = true;
      _timerSeconds = 3;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_timerSeconds > 1) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isCountingDown = false;
        });
        await _takePhoto();
      }
    });
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    try {
      final XFile rawPhoto = await _cameraController!.takePicture();
      final File savedFile = File(rawPhoto.path);

      setState(() {
        _capturedFiles.add(savedFile);
        _currentCaptureIndex++;
      });

      if (_currentCaptureIndex >= widget.requiredPhotos) {
        Navigator.pop(context, _capturedFiles);
      }
    } catch (e) {
      debugPrint('사진 촬영 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '부스 촬영중 (${_currentCaptureIndex + 1}/${widget.requiredPhotos}컷)',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined),
            onPressed: _isCountingDown ? null : _toggleCamera,
          ),
        ],
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize!.height,
                              height: _cameraController!.value.previewSize!.width,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ),
                      ),
                      if (_isCountingDown)
                        Container(
                          color: Colors.black45,
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              '$_timerSeconds',
                              key: ValueKey<int>(_timerSeconds),
                              style: const TextStyle(
                                color: Colors.yellowAccent,
                                fontSize: 120,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white12, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.grey[950],
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.requiredPhotos,
                          itemBuilder: (context, idx) {
                            final bool isFilled = idx < _capturedFiles.length;
                            return Container(
                              width: 55,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                border: Border.all(
                                  color: _currentCaptureIndex == idx
                                      ? Colors.blueAccent
                                      : Colors.grey[700]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: isFilled
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: Image.file(_capturedFiles[idx], fit: BoxFit.cover),
                                    )
                                  : const Center(
                                      child: Icon(Icons.image, color: Colors.white24, size: 20),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isCountingDown ? null : _triggerCountdown,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(22),
                          ),
                          child: const Icon(Icons.camera, size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
    );
  }
}