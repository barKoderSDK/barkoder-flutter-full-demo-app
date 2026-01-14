import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HistoryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const HistoryHeader({
    super.key,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/chevron.svg', height: 18),
            onPressed: onBack,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(width: 8),
          const Text(
            'Recent Scans',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
