import 'dart:io';
import 'package:flutter/material.dart';
import 'gallery_screen.dart'; // SavedPhoto 클래스를 사용하기 위해

class SearchResultScreen extends StatelessWidget {
  final List<SavedPhoto> foundPhotos;

  const SearchResultScreen({super.key, required this.foundPhotos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Found ${foundPhotos.length} Photos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: foundPhotos.length,
        itemBuilder: (context, index) {
          final photo = foundPhotos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(photo.path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[300], child: const Icon(Icons.broken_image)),
            ),
          );
        },
      ),
    );
  }
}