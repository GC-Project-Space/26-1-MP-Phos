import 'dart:io';
import 'package:flutter/material.dart';
import '../models/frame_design.dart';

class CustomFourCutFrame extends StatelessWidget {
  final List<File?> images;
  final FrameType frameType;
  final FrameDesign design;
  final Function(int index)? onPhotoTap;

  const CustomFourCutFrame({
    Key? key,
    required this.images,
    required this.frameType,
    required this.design,
    this.onPhotoTap,
  }) : super(key: key);

  Size _getFrameSize() {
    switch (frameType) {
      case FrameType.grid2x2:
        return const Size(320, 420);
      case FrameType.strip1x4:
        return const Size(160, 520);
      case FrameType.strip1x3:
        return const Size(160, 410);
    }
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = _getFrameSize();

    return Container(
      width: frameSize.width,
      height: frameSize.height,
      decoration: design.decoration,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 14.0),
      child: Column(
        children: [
          Expanded(child: _buildPhotosLayout()),
          const SizedBox(height: 10),
          Text(
            design.brandText,
            style: TextStyle(
              color: design.textColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.5,
              fontFamily: 'Courier',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosLayout() {
    switch (frameType) {
      case FrameType.grid2x2:
        return Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPhotoCell(0)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildPhotoCell(1)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildPhotoCell(2)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildPhotoCell(3)),
                ],
              ),
            ),
          ],
        );

      case FrameType.strip1x4:
        return Column(
          children: [
            Expanded(child: _buildPhotoCell(0)),
            const SizedBox(height: 5),
            Expanded(child: _buildPhotoCell(1)),
            const SizedBox(height: 5),
            Expanded(child: _buildPhotoCell(2)),
            const SizedBox(height: 5),
            Expanded(child: _buildPhotoCell(3)),
          ],
        );

      case FrameType.strip1x3:
        return Column(
          children: [
            Expanded(child: _buildPhotoCell(0)),
            const SizedBox(height: 6),
            Expanded(child: _buildPhotoCell(1)),
            const SizedBox(height: 6),
            Expanded(child: _buildPhotoCell(2)),
          ],
        );
    }
  }

  Widget _buildPhotoCell(int index) {
    final File? imgFile = (index < images.length) ? images[index] : null;

    return GestureDetector(
      onTap: onPhotoTap != null ? () => onPhotoTap!(index) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[350],
          borderRadius: BorderRadius.circular(1.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: imgFile != null
            ? Image.file(
                imgFile,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : const Center(
                child: Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.black26,
                  size: 18,
                ),
              ),
      ),
    );
  }
}