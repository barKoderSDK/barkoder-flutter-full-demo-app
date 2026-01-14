import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AboutHeader extends StatelessWidget {
  const AboutHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SvgPicture.asset('assets/icons/chevron.svg', height: 18),
            ),
          ),
          const SizedBox(width: 12),
          SvgPicture.asset('assets/images/logo_barkoder.svg', height: 18),
        ],
      ),
    );
  }
}
