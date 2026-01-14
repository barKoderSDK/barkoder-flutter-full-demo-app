import 'dart:typed_data';
import 'package:flutter/material.dart';

class ScannerOverlay extends StatelessWidget {
  final Uint8List? imageBytes;
  final VoidCallback onTap;

  const ScannerOverlay({
    super.key,
    required this.imageBytes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            image: imageBytes != null
                ? DecorationImage(
                    image: MemoryImage(imageBytes!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: imageBytes == null ? Colors.black.withValues(alpha: 0.7) : null,
          ),
        ),
      ),
    );
  }
}
