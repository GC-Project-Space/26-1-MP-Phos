// lib/screens/gallery_screen.dart
import 'dart:convert'; // JSON 데이터를 다루기 위해 필요
import 'dart:io';     // 파일 시스템(사진 파일 등)을 다루기 위해 필요
import 'dart:math';   // 수학 함수(sqrt)를 사용하기 위해 필요 (코사인 유사도 계산)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 갤러리에서 사진을 가져오기 위해 필요
import 'package:shared_preferences/shared_preferences.dart'; // 기기 내 간단한 데이터 저장을 위해 필요

import '../core/constants.dart'; // 앱에서 공통으로 사용하는 색상, 프레임 타입 등
import '../services/face_recognition_service.dart' hide FrameType;
import 'frame_conversion_screen.dart'; // '프레임 변환하기' 화면으로 이동하기 위해
import 'search_result_screen.dart'; // '인물 검색 결과' 화면으로 이동하기 위해

/// 앱 갤러리에 저장된 사진 한 장의 정보를 담는 클래스(설계도)
class SavedPhoto {
  final String path;      // 사진 파일이 저장된 실제 경로
  final FrameType frameType; // 어떤 프레임이 적용되었는지 (e.g., 4x1, 2x2)
  final String title;     // 사진 제목 (사용자가 수정 가능)
  final String tag;       // 사진 태그

  // SavedPhoto 객체를 만들 때 필요한 재료들을 정의
  SavedPhoto({required this.path, required this.frameType, required this.title, required this.tag});
}

/// 갤러리 화면 전체를 담당하는 위젯
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

/// GalleryScreen 위젯의 실제 상태와 로직을 관리하는 클래스
class _GalleryScreenState extends State<GalleryScreen> {
  // --- 상태 변수 선언 영역 --- //

  // 현재 선택된 프레임 필터 (기본값: 4x1 클래식)
  FrameType _selectedFilter = FrameType.classic;
  // 텍스트 검색창이 활성화되었는지 여부
  bool _isSearchActive = false;
  // 텍스트 검색창에 입력된 내용을 관리하는 컨트롤러
  final TextEditingController _searchController = TextEditingController();
  // 현재 검색어
  String _searchQuery = '';
  // SharedPreferences에서 불러온 모든 사진 정보를 담는 리스트
  List<SavedPhoto> _myGallery = [];
  // 데이터를 불러오는 중인지 여부 (로딩 인디케이터 표시용)
  bool _isLoading = true;
  // SharedPreferences의 인스턴스를 저장해두고 계속 사용하기 위한 변수
  late SharedPreferences prefs;

  // --- 위젯 생명주기 및 초기화 함수 --- //

  /// 위젯이 처음 화면에 생성될 때 딱 한 번 호출되는 함수
  @override
  void initState() {
    super.initState();
    // 비동기 작업(데이터 로딩 등)을 처리하기 위한 별도의 초기화 함수를 호출
    _initialize();
  }

  /// SharedPreferences를 초기화하고 저장된 사진 데이터를 불러오는 비동기 함수
  Future<void> _initialize() async {
    // SharedPreferences 인스턴스를 가져와 prefs 변수에 저장
    prefs = await SharedPreferences.getInstance();
    // 저장된 사진 목록을 불러오는 함수를 호출 (await로 끝날 때까지 기다림)
    await _loadSavedPhotos();
  }

  // --- 얼굴 인식 관련 함수 --- //

  /// '인물로 검색' 버튼을 눌렀을 때 실행되는 메인 함수
  Future<void> _searchByFace() async {
    // 1. 디바이스 갤러리를 열어 사용자가 기준이 될 사진을 선택하도록 함
    final XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // 사용자가 사진을 선택하지 않고 창을 닫으면 함수 종료
    if (imageFile == null) return;

    // 2. 선택한 사진에서 얼굴 특징(Embedding)을 추출
    final targetEmbeddings = await FaceRecognitionService().getEmbeddings(imageFile);
    // 얼굴을 찾지 못했다면 사용자에게 알리고 함수 종료
    if (targetEmbeddings.isEmpty) {
      if (!mounted) return; // 위젯이 화면에 없으면 아무 작업도 하지 않음
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('선택한 사진에서 얼굴을 인식할 수 없습니다.')),
      );
      return;
    }
    // 사진에 여러 얼굴이 있을 경우, 첫 번째로 찾은 얼굴을 기준으로 삼음
    final targetEmbedding = targetEmbeddings.first;

    // --- [새로 추가된 부분] ---
    // 3. 추출된 얼굴 특징(embedding)을 SharedPreferences에 저장
    //    (나중에 이 사진을 기준으로 검색할 때 사용될 수 있도록)
    await FaceRecognitionService().saveEmbeddings(imageFile.path, targetEmbeddings);
    // --------------------------
    // 4. 기준 얼굴과 갤러리의 모든 사진들을 비교하여 비슷한 사진을 찾아냄
    final List<SavedPhoto> similarPhotos = await _findSimilarPhotos(targetEmbedding);

    // 5. 비슷한 사진을 찾지 못했다면 사용자에게 알리고 함수 종료
    if (!mounted) return;
    if (similarPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동일 인물 사진을 찾지 못했습니다.')),
      );
      return;
    }

    // 6. 찾은 사진 목록을 가지고 결과 화면으로 이동
                    Navigator.push(
                      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(foundPhotos: similarPhotos),
                  ),
                );
  }

  /// 기준 얼굴 특징(targetEmbedding)과 갤러리의 모든 사진을 비교하는 함수
  Future<List<SavedPhoto>> _findSimilarPhotos(List<double> targetEmbedding) async {
    List<SavedPhoto> similarPhotos = [];
    // 임계값 조정 (모델에 따라 최적 값이 다를 수 있습니다. 0.5부터 시작)
    const double threshold = 0.5; // 임계값

    final savedStrings = prefs.getStringList('phos_gallery_data') ?? [];
    if (savedStrings.isEmpty) return [];

    print('--- Comparing with target embedding (length: ${targetEmbedding.length}) ---'); // 타겟 임베딩 길이 확인

    for (SavedPhoto photo in _myGallery) {
      try {
        final photoDataString = savedStrings.firstWhere(
          (element) => jsonDecode(element)['path'] == photo.path,
          orElse: () => '{}',
        );
        if (photoDataString == '{}') continue;

        final Map<String, dynamic> photoData = jsonDecode(photoDataString);
        // SharedPreferences에서 불러온 embeddings는 List<String> 형태일 것입니다.
        final List<dynamic>? savedEmbeddingsStrings = photoData['embeddings'];
        if (savedEmbeddingsStrings == null || savedEmbeddingsStrings.isEmpty) {
           print('📸 Photo ${photo.title} has no embeddings saved. Skipping.');
             continue;
          }

        bool foundMatch = false;
        for (var embeddingString in savedEmbeddingsStrings) { // List<String>을 순회
          if (embeddingString is String) { // 각 항목이 String인지 확인
      try {
              final List<dynamic> decodedEmbeddings = jsonDecode(embeddingString);
              List<double> comparisonEmbedding = [];
              if (decodedEmbeddings is List) { // JSON 디코딩 결과가 List인지 확인
                for (var item in decodedEmbeddings) {
              if (item is double) {
                    comparisonEmbedding.add(item);
                  } else if (item is num) {
                    comparisonEmbedding.add(item.toDouble());
                  } else {
                    print('⚠️ Unexpected type in embedding data: ${item.runtimeType} for photo: ${photo.title}');
            }
            }

                // 저장된 임베딩의 길이가 targetEmbedding의 길이와 같은지 확인
                if (comparisonEmbedding.length == targetEmbedding.length) { // targetEmbedding의 길이에 맞춰 동적으로 비교
                final double similarity = _cosineSimilarity(targetEmbedding, comparisonEmbedding);

                if (similarity > threshold) {
                  foundMatch = true;
        break;
      }
              } else {
                  // 길이가 다르면 비교하지 않고 로그 남기기
                  print('📏 Length mismatch for photo ${photo.title}: Target(${targetEmbedding.length}) vs Saved(${comparisonEmbedding.length}). Skipping comparison.');
                  continue;
    }
          } else {
                print('🚫 Invalid decoded embedding format (not a List). Photo: ${photo.title}, Data: $decodedEmbeddings');
          }
            } catch (e) { // JSON 디코딩 오류 처리
              print('❌ Embeddings 파싱 오류: ${embeddingString}');
        }
        } else {
             print('🚫 Invalid embedding format in SharedPreferences (not a String). Photo: ${photo.title}, Data: $embeddingString');
        }
        }
        if (foundMatch) {
          similarPhotos.add(photo);
        }
      } catch (e, stacktrace) {
        debugPrint('사진 처리 중 치명적인 오류 발생 (${photo.path}): $e\n$stacktrace');
      }
    }
    print('--- Comparison finished. Found ${similarPhotos.length} similar photos. ---');
    return similarPhotos;
  }

  /// 두 벡터(얼굴 특징) 간의 코사인 유사도를 계산하는 수학 함수
  double _cosineSimilarity(List<double> v1, List<double> v2) {
    // 예외 처리: 벡터가 비어있거나 길이가 다르면 계산 불가
    // 이제 두 벡터 모두 길이가 같아야 합니다.
    if (v1.isEmpty || v2.isEmpty || v1.length != v2.length) return 0.0;
    double dotProduct = 0.0; // 내적
    double normV1 = 0.0;     // 벡터1의 크기
    double normV2 = 0.0;     // 벡터2의 크기

    for (int i = 0; i < v1.length; i++) {
      dotProduct += v1[i] * v2[i];
      normV1 += v1[i] * v1[i];
      normV2 += v2[i] * v2[i];
    }
    // 0으로 나누는 것을 방지
    if (normV1 == 0 || normV2 == 0) return 0.0;
    // 유사도 공식 적용
    return dotProduct / (sqrt(normV1) * sqrt(normV2));
  }

  // --- 데이터 관리 함수 (CRUD) --- //

  /// SharedPreferences에서 저장된 모든 사진 데이터를 불러와 _myGallery 리스트를 채우는 함수
  Future<void> _loadSavedPhotos() async {
    List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];
    List<SavedPhoto> loadedPhotos = [];

    for (String jsonStr in savedStrings) {
      try {
        Map<String, dynamic> data = jsonDecode(jsonStr);

        FrameType? type;
        if (data.containsKey('frameType') && data['frameType'] is String) {
          try {
            type = FrameType.values.byName(data['frameType']);
          } catch (e) {
            print('FrameType 변환 오류: ${data['frameType']}');
            type = FrameType.classic;
      }
        } else {
          type = FrameType.classic;
    }

        List<List<double>> embeddings = [];
        // data['embeddings']가 List<String>인지 명확하게 확인
        if (data.containsKey('embeddings') && data['embeddings'] is List) {
          for (var embeddingData in data['embeddings'] as List<dynamic>) { // List<dynamic>으로 가정
            if (embeddingData is String) { // 각 항목이 String이어야 함 (JSON 문자열)
              try {
                final List<dynamic> decodedEmbedding = jsonDecode(embeddingData); // JSON 디코딩
                List<double> currentEmbedding = [];
                if (decodedEmbedding is List) { // 디코딩 결과가 List인지 확인
                  for (var item in decodedEmbedding) {
                    if (item is double) {
                      currentEmbedding.add(item);
                    } else if (item is num) {
                      currentEmbedding.add(item.toDouble());
                    } else {
                      print('⚠️ Unexpected type in embedding data: ${item.runtimeType} for photo: ${data['path']}');
  }
                  }
                  // 저장된 임베딩의 길이가 512인지 확인
                  if (currentEmbedding.length == 512) {
                    embeddings.add(currentEmbedding);
                  } else {
                    print('❌ Embedding length mismatch. Expected 512, got ${currentEmbedding.length} for photo: ${data['path']}');
                  }
                } else {
                  print('🚫 Invalid decoded embedding format (not a List). Photo: ${data['path']}, Data: $decodedEmbedding');
                }
              } catch (e) {
                print('Embeddings 파싱 오류 (JSON 디코딩 실패): $embeddingData');
              }
            } else {
               print('🚫 Invalid embedding format in SharedPreferences (expected String, got ${embeddingData.runtimeType}). Photo: ${data['path']}');
            }
          }
          if (embeddings.isEmpty && data['embeddings'].isNotEmpty) {
             print('❗️ No valid embeddings loaded for photo: ${data['path']} after parsing.');
          } else {
             print('✅ Successfully loaded ${embeddings.length} embeddings for photo: ${data['path']}');
          }
        } else {
           print('Embeddings 키가 없거나, List<String> 형식이 아닙니다. photo: ${data['path']}');
        }

        loadedPhotos.add(SavedPhoto(
          path: data['path'] ?? '',
          frameType: type ?? FrameType.classic,
          title: data['title'] ?? 'Untitled',
          tag: data['tag'] ?? 'untagged',
        ));
      } catch (e, stacktrace) {
        debugPrint('사진 데이터 처리 중 오류 발생: $e\n$stacktrace');
      }
    }
    if(mounted) {
                    setState(() {
        _myGallery = loadedPhotos.reversed.toList();
        _isLoading = false;
    });
                      }
  }

  /// 사진 경로(targetPath)를 기준으로 사진 제목을 변경하는 함수
  Future<void> _updatePhotoTitle(String targetPath, String newTitle) async {
    List<String> savedStrings = prefs.getStringList('phos_gallery_data') ?? [];

    for (int i = 0; i < savedStrings.length; i++) {
      Map<String, dynamic> data = jsonDecode(savedStrings[i]);
      if (data['path'] == targetPath) {
        data['title'] = newTitle;
        savedStrings[i] = jsonEncode(data); // 수정된 데이터를 다시 JSON 문자열로 변환하여 덮어쓰기
        break;
      }
    }
    await prefs.setStringList('phos_gallery_data', savedStrings); // 변경된 리스트를 다시 저장
    await _loadSavedPhotos(); // 화면을 새로고침하기 위해 데이터를 다시 불러옴
  }

  /// 사진 제목을 수정하는 팝업창(Dialog)을 띄우는 함수
  void _showEditTitleDialog(SavedPhoto photo) {
    TextEditingController editController = TextEditingController(text: photo.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('사진 이름 수정'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(hintText: "새로운 이름을 입력하세요"),
            autofocus: true,
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
                      ),
            ElevatedButton(
                  onPressed: () {
                if (editController.text.trim().isNotEmpty) {
                  _updatePhotoTitle(photo.path, editController.text.trim());
  }
                Navigator.pop(context);
                  },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('저장', style: TextStyle(color: Colors.white)),
      ),
              ],
        );
      },
                );
}

  /// FrameType enum 값을 UI에 표시할 문자열로 변환하는 함수
  String _getFrameLabel(FrameType type) {
    switch (type) {
      case FrameType.classic: return '4x1';
      case FrameType.square: return '2x2';
      case FrameType.trio: return '3x1';
      case FrameType.solo: return '1x1';
    }
  }

  // --- UI 빌드 함수 --- //

  /// 화면을 그리는 메인 함수
  @override
  Widget build(BuildContext context) {
    // 현재 필터와 검색어에 맞는 사진들만 걸러냄
    final filteredGallery = _myGallery.where((photo) {
      final matchesFilter = photo.frameType == _selectedFilter;
      final matchesSearch = photo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            photo.tag.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
          // 1. 상단 앱바 영역
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // '인물로 검색' 버튼
                IconButton(
                  icon: const Icon(Icons.face_retouching_natural, color: AppColors.primary),
                  onPressed: _searchByFace,
                                ),
                // 앱 로고
                const Text('pho\'s', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                // '텍스트로 검색' 버튼 (검색창 토글)
                IconButton(
                  icon: const Icon(Icons.search, color: AppColors.primary),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = !_isSearchActive;
                      if (!_isSearchActive) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    });
                        },
                      ),
        ],
            ),
      ),

          // 2. 텍스트 검색창 (활성화되었을 때만 보임)
          if (_isSearchActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0).copyWith(bottom: 15),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '사진 이름이나 태그로 검색...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
      ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

          // 3. 'Your Gallery' 타이틀 및 '프레임 변환' 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Gallery', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FrameConversionScreen()),
    );
                  },
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('프레임 변환하기', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 4. 프레임 종류별 필터 칩
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: FrameType.values.map((frame) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = frame),
                    child: _buildFilterChip(_getFrameLabel(frame), _selectedFilter == frame),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // 5. 갤러리 그리드 영역
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator()) // 로딩 중일 때
                : filteredGallery.isEmpty
                    ? const Center(child: Text('해당하는 사진이 없습니다.', style: TextStyle(color: Colors.grey))) // 결과가 없을 때
                    : GridView.builder( // 사진 목록
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: filteredGallery.length,
                        itemBuilder: (context, index) {
                          final photo = filteredGallery[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // 사진 이미지
                                Image.file(
                                  File(photo.path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                    Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                                ),
                                // 하단 제목/태그 오버레이
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  child: Container(
                                    color: Colors.black.withOpacity(0.5),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      '${photo.title}\n#${photo.tag}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                // 우측 상단 수정 버튼
                                Positioned(
                                  top: 5, right: 5,
                                  child: GestureDetector(
                                    onTap: () => _showEditTitleDialog(photo),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
}

  /// 필터 칩 위젯을 만드는 함수
  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
      ),
    );
}
}

