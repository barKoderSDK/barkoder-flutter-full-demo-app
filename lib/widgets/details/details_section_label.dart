import 'package:flutter/material.dart';

class DetailsSectionLabel extends StatelessWidget {
  const DetailsSectionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4),
      child: Text(
        'DATA',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE52E4C),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
