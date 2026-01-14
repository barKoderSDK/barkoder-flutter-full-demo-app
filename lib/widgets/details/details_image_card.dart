import 'package:flutter/material.dart';
import 'dart:io';

class DetailsImageCard extends StatelessWidget {
  final String? imagePath;

  const DetailsImageCard({
    super.key,
    required this.imagePath,
  });

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
      child: imagePath != null && File(imagePath!).existsSync()
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(imagePath!),
                fit: BoxFit.contain,
                height: 180,
              ),
            )
          : Icon(
              Icons.image_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
    );
  }
}
