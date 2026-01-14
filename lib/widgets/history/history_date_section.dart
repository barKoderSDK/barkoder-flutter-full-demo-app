import 'package:flutter/material.dart';

class HistoryDateSection extends StatelessWidget {
  final String dateLabel;

  const HistoryDateSection({
    super.key,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 12, bottom: 8),
      child: Text(
        dateLabel,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE52E4C),
        ),
      ),
    );
  }
}
