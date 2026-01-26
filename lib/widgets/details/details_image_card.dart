import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class DetailsImageCard extends StatelessWidget {
  final String? imagePath;

  const DetailsImageCard({super.key, required this.imagePath});

  Widget _buildImage() {
    if (imagePath == null) {
      return Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade300);
    }

    if (imagePath!.startsWith('data:image')) {
      try {
        final base64String = imagePath!.split(',')[1];
        final bytes = base64Decode(base64String);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes, fit: BoxFit.contain, height: 180),
        );
      } catch (e) {
        return Icon(
          Icons.image_outlined,
          size: 80,
          color: Colors.grey.shade300,
        );
      }
    }

    if (File(imagePath!).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(imagePath!), fit: BoxFit.contain, height: 180),
      );
    }

    return Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade300);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildImage(),
    );
  }
}
