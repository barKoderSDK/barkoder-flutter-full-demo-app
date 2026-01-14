import 'package:flutter/material.dart';

class AboutLinkButton extends StatelessWidget {
  final String label;
  final String url;
  final Function(String) onTap;

  const AboutLinkButton({
    super.key,
    required this.label,
    required this.url,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(url),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFFE52E4C)),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFE52E4C),
            ),
          ],
        ),
      ),
    );
  }
}
