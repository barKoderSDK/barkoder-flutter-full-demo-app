import 'package:flutter/material.dart';

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No scans yet',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
